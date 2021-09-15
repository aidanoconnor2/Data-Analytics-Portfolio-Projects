-- Data Cleaning Project for Nashville Housing

-- We will clean this dataset by:
-- Dropping unrequired information. 
-- Populating null values. 
-- Splitting up data in certain columns into multiple columns.
-- Identifying and removing duplicates.

-------------------------------------------------------------------------------------------------------------

-- Let's start by taking a look at the data:
select * from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------

-- Standardize/ Change Sale Date so it doesn't show the time at the end

select SaleDate, convert(date,SaleDate) from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

-------------------------------------------------------------------------------------------------------------

-- Populate Property address data

select PropertyAddress from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
-- Many of these values in the property address fields are null. Let's try to popluate them

-- First, let;'s order by parcel ID
select * from PortfolioProject.dbo.NashvilleHousing
order by ParcelID
-- Looking at the data, we see that the parcelID and PropertyAddress are always the same. 
--So let's use this knowledge to populate null values in the PropertyAddress column

-------------------------------------------------------------------------------------------------------------

-- Fixing null values in property address

-- Self join with PropertyAddress
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] -- Making sure all of the data, including repeat instances of ParcelID is retained in the join
where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------

-- Brekaing up address into individual columns (street address and city)

-- Splitting the address and city up using the substring aggregate function
select
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,1,charindex(',',PropertyAddress)+1) as City
from PortfolioProject.dbo.NashvilleHousing

-- Adding new columns and updating them with the split data:
alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,1,charindex(',',PropertyAddress)+1)

-------------------------------------------------------------------------------------------------------------

-- Doing the same with the owner's address! (split up into street address, city and state)

select OwnerAddress from PortfolioProject.dbo.NashvilleHousing

-- Doing the same as above, except the street address, city and state are split up using parsename instead of substring
select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

-- Adding new columns and updating them with the split data:
alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-------------------------------------------------------------------------------------------------------------

-- Clean up SoldAsVacant

-- Let's see all of the different values SoldAsVacant has
select Distinct(SoldAsVacant) from PortfolioProject.dbo.NashvilleHousing
-- There are various versions of "yes" and "no". Let's standardize it

-- Get a fell for how many of each there is
select SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

-- Change the data
update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
end

-------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Let's first identify duplicates. Then, once identified, we'll remove them.

-- Looking at the data, entries which all have the same ParcelID, PropertyAddress, SalePrice, SaleDate and LegalReference can be considered "duplicates".
-- Therefore, we will find duplicate entries based on this. 

-- We will identify them using row_number.
with RowNumCTE as(
	select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				uniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
)
-- This counts how many times entries which all have the same ParcelID, PropertyAddress, SalePrice, SaleDate and LegalReference show up.
-- An entry with a "2" in the row_num column is a duplicate. Let's take look to see if it worked.

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Now we wll remove anything with a value of 2 in its row_num column:
with RowNumCTE as(
	select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
				uniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1

-------------------------------------------------------------------------------------------------------------

-- Delete unused columns.
-- Some of these are columns in which the data was converted or split and was put into other, newly generated columns.

select * from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict