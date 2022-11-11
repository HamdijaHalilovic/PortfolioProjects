--Cleaning Data in SQL Queries

-- Standardize date format

Select SaleDateConverted
From HousingNashville

ALTER TABLE HousingNashville
Add SaleDateConverted Date

Update HousingNashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data
Select *
From HousingNashville
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingNashville a
join HousingNashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingNashville a
join HousingNashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-- Seprate Address into own columns (Address, city, state)

Select PropertyAddress
From HousingNashville

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From HousingNashville

ALTER TABLE HousingNashville
Add PropertySplitAddress Nvarchar(255)

Update HousingData.dbo.HousingNashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData.dbo.HousingNashville
ALTER COLUMN PropertySplitCity Nvarchar(255)

Update HousingData.dbo.HousingNashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From HousingData.dbo.HousingNashville

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From HousingData.dbo.HousingNashville

ALTER TABLE HousingData.dbo.HousingNashville
Add OwnerSplitAddress Nvarchar(255)

Update HousingData.dbo.HousingNashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE HousingData.dbo.HousingNashville
Add OwnerSplitCity Nvarchar(255)

Update HousingData.dbo.HousingNashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE HousingData.dbo.HousingNashville
Add OwnerSplitState Nvarchar(255)

Update HousingData.dbo.HousingNashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

-- Sold as vacant to yes/no

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from HousingNashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from HousingNashville

Update HousingNashville
SET SoldAsVacant =
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
-- remove duplicates
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

From HousingNashville
--order by ParcelID
)

Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress

-- delete unused columns

Select *
From HousingNashville

ALTER TABLE HousingNashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingNashville
DROP COLUMN SaleDate