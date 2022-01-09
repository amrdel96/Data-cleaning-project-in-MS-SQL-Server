use [Housing DB]

--Cleaning Data in SQL Queries

Select *
From NashvilleHousing


-- Standardize Date Format

Select saleDate, CONVERT(Date,SaleDate)
From NashvilleHousing

Alter table  NashvilleHousing
Alter column SaleDate  Date


--------------------------------------------------
-- Populate Property Address data

Select *
From NashvilleHousing
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress
From NashvilleHousing a  
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a inner JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NashvilleHousing



-------------------------------------------------------------------------------
 --Breaking out Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnersplitAddress
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as Ownersplitcity
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as Ownersplitstate
From NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From NashvilleHousing


----------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2



Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



---------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
delete
From RowNumCTE
Where row_num > 1



-----------------------------------------------------
-- Delete Unused Columns


Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
