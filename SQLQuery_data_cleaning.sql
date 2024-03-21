/* Data cleaning in SQL */


select * from nashville_house


-- standardize date format

select SaleDate, CONVERT(Date, SaleDate) as sale_date
from nashville_house

alter table nashville_house
add sale_date Date;

update nashville_house
set sale_date = SaleDate


select *
from Nashville.dbo.nashville_house



--where PropertyAddress is null



order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville.dbo.nashville_house a
join Nashville.dbo.nashville_house b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville.dbo.nashville_house a
join Nashville.dbo.nashville_house b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]



-- breaking adress in individual columns


select PropertyAddress
from Nashville.dbo.nashville_house

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as adress
from Nashville.dbo.nashville_house

alter table nashville_house
add prop_split Nvarchar(255)

update nashville_house
set prop_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table nashville_house
add prop_split_city Nvarchar(255)


update nashville_house
set prop_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


select*from nashville_house

select OwnerAddress
from nashville_house

select 
PARSENAME(replace(OwnerAddress,',','.') ,3)
,PARSENAME(replace(OwnerAddress,',','.') ,2)
,PARSENAME(replace(OwnerAddress,',','.') ,1)
from nashville_house

alter table nashville_house
add own_prop_split Nvarchar(255)

update nashville_house
set own_prop_split = PARSENAME(replace(OwnerAddress,',','.') ,3)

alter table nashville_house
add own_split_city Nvarchar(255)

update nashville_house
set own_split_city = PARSENAME(replace(OwnerAddress,',','.') ,2)

alter table nashville_house
add own_split_state Nvarchar(255)

update nashville_house
set own_split_state = PARSENAME(replace(OwnerAddress,',','.') ,1)


select distinct SoldAsVacant, count(SoldAsVacant) as numero
from nashville_house 
group by SoldAsVacant

--standardize the SoldasVacant column with only yes or no values

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_house


update nashville_house
set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from nashville_house;


--remove duplicates


WITH RowNumCTE as
(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 sale_date,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
	From nashville_house
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

WITH RowNumCTE as
(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 sale_date,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
	From nashville_house
)
Delete
From RowNumCTE
where row_num > 1


WITH RowNumCTE as
(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 sale_date,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
	From nashville_house
)
select *
From RowNumCTE
where row_num > 1






