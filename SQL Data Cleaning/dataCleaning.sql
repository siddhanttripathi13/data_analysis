/*
Cleaning Data in SQL Queries
*/

SELECT * FROM Housing
ORDER BY ParcelID;

---------------------------------------------------------------------------

--Handle null values in Property Address Data--

SELECT *
FROM Housing
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID;


--------------------------------------------------------------------------

-- Splitting Property address into street and city--

SELECT propertyaddress
FROM Housing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) PropertyStreet
FROM Housing

SELECT SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) PropertyCity
FROM Housing

ALTER TABLE Housing ADD PropertyStreet NVARCHAR(255);

UPDATE Housing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Housing ADD PropertyCity NVARCHAR(255);

UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


----------------------------------------------------------------------------------------------------------------

-- Splitting Owner address into street, city and state--

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) OwnerAddress
FROM Housing



ALTER TABLE Housing ADD OwnerStreet NVARCHAR(255);

UPDATE Housing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Housing ADD OwnerCity NVARCHAR(255);

UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Housing ADD OwnerState NVARCHAR(255);

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-------------------------------------------------------------------------------------------------------------

--Remove Duplicates--

WITH RowNumCTE
AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference ORDER BY UniqueID
			) row_num
	FROM Housing
	)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns--

SELECT *
FROM housing;

ALTER TABLE Housing

DROP COLUMN OwnerAddress,
	TaxDistrict,
	PropertyAddress;




