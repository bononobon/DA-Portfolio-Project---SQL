-- DATA CLEANING IN SQL
-- Inspecting data and Counting the rows of the uploaded dataset

SELECT COUNT(*)
FROM PortfolioProject_NashvilleHousingData..[Nashville Housing Data]

-------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET SaleDate = CONVERT(date, SaleDate)

------------------------------------------

-- Populate Property Address data (fixing NULL value)

SELECT *
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
WHERE PropertyAddress IS NULL

-- The Property with same parcelID should have the same address

SELECT ParcelID, PropertyAddress
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

-- Joining the same table to replace NULL value

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS PropertyAddUpdated
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data a
JOIN PortfolioProject_NashvilleHousingData..Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data a
JOIN PortfolioProject_NashvilleHousingData..Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------

-- Seperating the address into individual columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

-- Adding new columns into the table

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
ADD PropertyAddressSplit nvarchar(255);

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
ADD PropertyCitySplit nvarchar(255);

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

-- Seperating OwnerAddress into multiple columns (address, city, state) using PARSENAME

SELECT OwnerAddress
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) OwnerState
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

--Updating OwnerAddress with new columns

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
ADD OwnerAddressSplit nvarchar(255);

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
ADD OwnerCitySplit nvarchar(255);

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
ADD OwnerStateSplit nvarchar(255);

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

----------------------------------------------------------------

--Changing Boolean Y and N into Yes and No for consistancy of data

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

UPDATE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END  

-------------------------------------------------

-- Remove Duplicates using CTE

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID) row_num

FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-------------------------------------------------------------

-- Delete Unused Columns (Dont delete on raw data, ok when creating view)

SELECT *
FROM PortfolioProject_NashvilleHousingData..Nashville_Housing_Data

ALTER TABLE PortfolioProject_NashvilleHousingData..Nashville_Housing_Data
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate