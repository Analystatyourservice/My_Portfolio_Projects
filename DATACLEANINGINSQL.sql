SELECT *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

--1.) Changing format of the date to MM-DD-YYYY

Select *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add ConvertedDate date;

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set ConvertedDate =convert(varchar(8),SaleDate, 110)

--2.)Populating Data from Property Address Data

Select *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

Select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING a
JOIN NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING a
JOIN NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--3.)Populating Data from Owner Address Data

Select *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Order by OwnerName, OwnerAddress

Select a.OwnerName,a.OwnerAddress,a.ParcelID,b.OwnerAddress,b.ParcelID, ISNULL(a.OwnerAddress,b.OwnerAddress)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING a
JOIN NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
Where a.OwnerAddress is null

Update a
Set OwnerAddress = ISNULL(a.OwnerAddress,b.OwnerAddress)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING a
JOIN NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
Where a.OwnerAddress is null

--4.) Separating address into individual Columns (Address, City, State)
--4.1) Propertyaddress Column

Select PropertyAddress
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

-- adding to columns for Address and City

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add PropertySplitAddress Nvarchar(255);

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add PropertySplitCity Nvarchar(255);

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

--4.2) OwnerAddress Column

Select OwnerAddress
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add OwnerSplitAddress Nvarchar(255);

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add OwnerSplitCity Nvarchar(255);

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2) 

Alter Table NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Add OwnerSplitState Nvarchar(255);

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 2) 

Select *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

--5.) Change Y and N to Yes and No data in SoldAsVacant Column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

Update NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

-- 6.) Removing Duplicates
-- 6.1) Using CTE

With RowNumCTE As (
Select *,	
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID ) row_num

FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order By PropertyAddress

-- 6.1) Deleting Duplicates by changing Select * to DELETE and by not including the Order By PropertyAddress then Check 6.1) if there are no duplicates after running 6.2

With RowNumCTE As (
Select *,	
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID ) row_num


--Order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--Order By PropertyAddress

--7.) DELETE UNUSED COLUMNS

Select *
FROM NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING

ALTER TABLE NASHVILLEHOUSINGDATACLEANING..NASHVILLEHOUSING
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict