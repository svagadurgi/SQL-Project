----------------------------------------------------------------------

/* Data Cleaning Project*/

-----------------------------------------------------------------------

USE PortfolioProject

EXEC sp_help 'dbo.NashvilleHousing'

Select * from NashvilleHousing

-------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate), Cast (SaleDate as Date)
From NashvilleHousing

Update NashvilleHousing 
Set SaleDate = Convert(Date, SaleDate)


Update NashvilleHousing 
Set SaleDate = Cast(SaleDate as Date)

Select SaleDate From NashvilleHousing

/*

Above Update Statement are not working, so lets try adding new column with Date as datatype

*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing 
SET [SaleDateConverted] = Convert(Date, SaleDate)

Select SaleDateConverted From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
 
Select * From NashvilleHousing 
Where PropertyAddress is null

/* 
Now Using Self Join on Same ParcelID & different UniqueID, Update where PropertyAddress is Null 
*/

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, B.PropertyAddress)
from NashvilleHousing a
	JOIN NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b. ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress From NashvilleHousing 
--Where PropertyAddress is null

Select PropertyAddress,
Substring(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1) Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress)) Address
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = Substring(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress))

---------------------------------------

Select OwnerAddress ,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD  
	OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255);


Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


Select * from NashvilleHousing

------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in 'SoldAsVacant'

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant


Select SoldAsVacant,
Case 
	When SoldAsVacant = 'N' then 'No'
	When SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case 
					When SoldAsVacant = 'N' then 'No'
					When SoldAsVacant = 'Y' then 'Yes'
					else SoldAsVacant
					End

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
(
Select *, 
		ROW_NUMBER() OVER(
							PARTITION BY
							ParcelID,
							PropertyAddress,
							SaleDate,
							SalePrice,
							LegalReference
							ORDER BY UniqueID
						) row_num
from NashvilleHousing
)
Select * from RowNumCTE
where row_num >1


WITH RowNumCTE AS
(
Select *, 
		ROW_NUMBER() OVER(
							PARTITION BY
							ParcelID,
							PropertyAddress,
							SaleDate,
							SalePrice,
							LegalReference
							ORDER BY UniqueID
						) row_num
from NashvilleHousing
)
DELETE 
from RowNumCTE
where row_num >1

------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
from NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN [OwnerAddress],[TaxDistrict],[PropertyAddress]

ALTER TABLE NashvilleHousing
DROP COLUMN [SaleDate]

