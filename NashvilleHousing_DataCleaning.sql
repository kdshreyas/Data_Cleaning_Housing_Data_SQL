use SQL_Data_Cleaning;
/*
Cleaning Data in SQL Queries
*/

select * from dbo.NashvilleHousing;

-- Standardize Date Format


Select saleDate From dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From dbo.NashvilleHousing

-- Dealing with nulls in Property Address column
Select * From dbo.NashvilleHousing
Where PropertyAddress is null 
order by ParcelID

-- populating null Property Address using common ParcelID

-- self join to get clear picture of ParcelID having null Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]  -- UniqueID should not be the same
Where a.PropertyAddress is null

-- updating null values in PropertyAddress

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From .dbo.NashvilleHousing a
JOIN .dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing

-- we have Address, City in PropertyAddress column

Select PropertyAddress
From dbo.NashvilleHousing
Where PropertyAddress is null

-- we do not have any null values in PropertyAddress column

-- checking weather any row do not follow  Address, City format in PropertyAddress column

select PropertyAddress from dbo.NashvilleHousing
where PropertyAddress not like '%,%'


Select PropertyAddress
From dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From dbo.NashvilleHousing

-- we are getting comma also and we don't want that

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From dbo.NashvilleHousing


-- Populating seperate Address and city table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select PropertySplitAddress,PropertySplitCity
From dbo.NashvilleHousing

-- we have added two new columns PropertySplitAddress,PropertySplitCity

Select OwnerAddress
From dbo.NashvilleHousing

-- dealing with OwnerAddress column

-- bydefault PARSENAME looks for period so we are converting comma
-- on to periods for splitting column

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

-- OwnerSplitAddress

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- OwnerSplitCity

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- OwnerSplitState
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--we have added three new columns OwnerSplitAddress,OwnerSplitCity,OwnerSplitState seperated from OwnerAddress column

Select * From dbo.NashvilleHousing

Select SoldAsVacant From dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field.

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	   END
From dbo.NashvilleHousing

-- Populating column with Yes and NO Values

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Remove Duplicates

Select *
From dbo.NashvilleHousing

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

From dbo.NashvilleHousing
--order by ParcelID
)
--DELETE
--From RowNumCTE
--Where row_num > 1
select *
From RowNumCTE
Where row_num > 1

-- removed 104 duplicate rows

Select *
From dbo.NashvilleHousing

-- Delete Unused Columns OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From dbo.NashvilleHousing



