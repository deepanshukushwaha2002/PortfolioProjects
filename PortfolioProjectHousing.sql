/*

Cleaning Data in SQL

*/

Select *
From Housing..NashvilleHousing




-- Standardize Date Format




Select SaleDate,CONVERT(date, SaleDate)
From Housing..NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted= CONVERT(date, SaleDate)

Select SaleDateConverted 
from Housing..NashvilleHousing




--Populate Property Address data




select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--Breaking out Address into Individual Columns (Address, city, State)



Select PropertyAddress
from Housing..NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from Housing..NashvilleHousing



Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1 )




Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))


Select *
from Housing..NashvilleHousing





Select OwnerAddress from Housing..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select * from NashvilleHousing


-- Change y and n to yes and no


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

select * from NashvilleHousing





--Remove Duplicates




Select *,
    ROW_NUMBER() Over (
	partition by ParcelID, PropertyAddress, SalePrice, Saledate, LegalReference
	order by UniqueID) row_num
from NashvilleHousing
order by ParcelID 

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() Over (
	partition by ParcelID, PropertyAddress, SalePrice, Saledate, LegalReference
	order by UniqueID) row_num
from NashvilleHousing
)

Select * from
RowNumCTE
where row_num >1




-- Delete Unused Columns




Select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate