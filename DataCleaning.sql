Select * 
from HousingData

-- Standardize Date Format

Select SaleDate, SaleDateConverted
from HousingData

Alter Table HousingData
add SaleDateConverted Date;

Update HousingData
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingData a
JOIN HousingData b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from HousingData a
JOIN HousingData b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns


Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From HousingData

Alter Table HousingData
Add PropertyAddress nvarchar(255);

update HousingData
set PropertyAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1)

Alter Table HousingData
Add PropertyCity nvarchar(255);

update HousingData
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
from HousingData


Alter Table HousingData
ADD OwnerSplitAddress nvarchar(255);

Update HousingData
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter Table HousingData
ADD OwnerSplitCity nvarchar(255);

Update HousingData
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter Table HousingData
ADD OwnerSplitState nvarchar(255);


Update HousingData
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)





select Distinct(SoldAsVacant), count(SoldAsVacant)
from HousingData
group by SoldAsVacant
order by 2


update HousingData
set SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end


-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelId,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM HousingData
)
-- Subsequent SQL statement that uses the CTE
Select *
FROM RowNumCTE



-- Delete Unused Columns

Alter Table HousingData
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



