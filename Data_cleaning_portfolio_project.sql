Select *
From PortfolioProject.dbo.NashvilleHousing

--Standartize date format

ALter table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------

--Populate property address data

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelId = b.ParcelId
	and a.UniqueId <> b.UniqueId
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------

--Breaking out Address into individual columns

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Town
From PortfolioProject.dbo.NashvilleHousing

ALter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

ALter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, len(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


ALter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

ALter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

ALter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = 'No'
Where SoldAsVacant = 'N'

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = 'Yes'
Where SoldAsVacant = 'Y'

--Remove duplicates


with RowNumCTE AS(
Select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				Saledate,
				Legalreference
				order by
				UniqueID
				) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1

--Delete unused columns


Select *
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


