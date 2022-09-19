/*
Data cleaning with SQL Queries
*/

USE PortfolioProject

SELECT * 
FROM NashvilleHousing

---------------------------------------------------
-- Standarize date format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(date,SaleDate)

--------------------------------------------
-- Populate Property Adress data

SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is null

SELECT a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------
--breaking out address into indivitual columns (Adress,City,State)

--property address
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAdress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAdress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--OwnerAddres
select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAdress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAdress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-----------------------------------------------------
-- Replacing Y and N to Yes and No in SoldAsVacant
Select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group By SoldAsVacant
order by 2

Select SoldAsVacant
,Case WHEN SoldAsVacant = 'y' then 'Yes'
	  WHEN SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END
from NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'y' then 'Yes'
	  WHEN SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END


-------------------------------------------------------
-- Remove Duplicates
WITH RowDupliCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
					) num_row
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
from RowDupliCTE
where num_row >1


-- remove unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate