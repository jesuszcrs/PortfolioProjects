/*

Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project]..[NashvilleHousing]


-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, saledate)
From [Portfolio Project]..[NashvilleHousing]

Update [Portfolio Project]..[NashvilleHousing]
set SaleDate = CONVERT(Date,saledate)

Alter Table [Portfolio Project]..[NashvilleHousing]
Add SaleDateConverted Date;

Update [Portfolio Project]..[NashvilleHousing]
set SaleDateConverted = CONVERT(date, saledate)

-- Populate Property Address Data

Select *
From [Portfolio Project]..[NashvilleHousing]
-- Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..[NashvilleHousing] a
Join [Portfolio Project]..[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..[NashvilleHousing] a
Join [Portfolio Project]..[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project]..[NashvilleHousing]
-- Where PropertyAddress is null
-- order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From [Portfolio Project]..[NashvilleHousing]

Alter Table [Portfolio Project]..[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project]..[NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [Portfolio Project]..[NashvilleHousing]
Add PropertySpliteCity Nvarchar(255);

Update [Portfolio Project]..[NashvilleHousing]
set PropertySpliteCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))







Select *
From [Portfolio Project]..NashvilleHousing


Select 
Parsename(Replace(OwnerAddress, ',', '.') , 3)
, Parsename(Replace(OwnerAddress, ',', '.') , 2)
, Parsename(Replace(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NashvilleHousing


Alter Table [Portfolio Project]..[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..[NashvilleHousing]
set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.') , 3)

Alter Table [Portfolio Project]..[NashvilleHousing]
Add OwnerSpliteCity Nvarchar(255);

Update [Portfolio Project]..[NashvilleHousing]
set OwnerSpliteCity = Parsename(Replace(OwnerAddress, ',', '.') , 2)

Alter Table [Portfolio Project]..[NashvilleHousing]
Add OwnerSpliteState Nvarchar(255);

Update [Portfolio Project]..[NashvilleHousing]
set OwnerSpliteState = Parsename(Replace(OwnerAddress, ',', '.') , 1)


Select *
From [Portfolio Project]..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End
From [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		End




-- Remove Duplicates

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over(
		Partition BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
						UniqueID
						) row_num
From [Portfolio Project]..NashvilleHousing
-- Order by ParcelID
)

Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress



-- Delete Unused Columns

Select * 
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column SaleDate

