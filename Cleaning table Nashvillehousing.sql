use portofolioproject;

--cleaning data in SQL queries

select*from [Nashville housing];

-- make standard date

use portofolioproject;

select*from [portofolioproject].[dbo].[Nashville housing];


select SaleDate from [portofolioproject].[dbo].[Nashville housing];

select SaleDate, CONVERT(date, SaleDate)
from [portofolioproject].[dbo].[Nashville housing];

update [portofolioproject].[dbo].[Nashville housing]
set SaleDate = CONVERT(date, SaleDate);

alter table [dbo].[Nashville housing]
add SaleDateConverted date;

update [dbo].[Nashville housing]
set SaleDateConverted=CONVERT(date, SaleDate);

select*from [Nashville housing];

--populate property address data

use portofolioproject;

select * from [dbo].[Nashville housing];

select *
from [dbo].[Nashville housing]
--where PropertyAddress is null;
order by ParcelID;

--filling in gaps in propertyaddress

select a.ParcelID, b.ParcelID,a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [dbo].[Nashville housing] a
join [dbo].[Nashville housing] b
on a.ParcelID =b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [dbo].[Nashville housing] a
join [dbo].[Nashville housing] b
on a.ParcelID =b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

select* from [dbo].[Nashville housing]
where PropertyAddress is null;

use portofolioproject;

--breaking out property adress into individual columns

use portofolioproject;

select * from [dbo].[Nashville housing];

select
substring(PropertyAddress, 1, charindex(',',PropertyAddress ) -1) as Adress,
 substring(PropertyAddress,charindex(',',PropertyAddress )+1, len(PropertyAddress)) as City
from [dbo].[Nashville housing];


alter table [dbo].[Nashville housing]
add PropertySplitAdress nvarchar(255);

update [dbo].[Nashville housing]
set PropertySplitAdress =substring(PropertyAddress, 1, charindex(',',PropertyAddress ) -1);



alter table [dbo].[Nashville housing]
add PropertySplitCity nvarchar(255);

update [dbo].[Nashville housing]
set PropertySplitCity =substring(PropertyAddress,charindex(',',PropertyAddress )+1, len(PropertyAddress));

select * from [dbo].[Nashville housing];


--breaking out owner adress into individual columns

select PropertyAddress, OwnerAddress, OwnerName from [dbo].[Nashville housing];


select 
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from [dbo].[Nashville housing];


alter table [dbo].[Nashville housing]
add OwnerSplitAdress nvarchar(255);

update [dbo].[Nashville housing]
set OwnerSplitAdress =PARSENAME(replace(OwnerAddress,',','.'), 3);



alter table [dbo].[Nashville housing]
add OwnerSplitCity nvarchar(255);

update [dbo].[Nashville housing]
set OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'), 2);


alter table [dbo].[Nashville housing]
add OwnerSplitState nvarchar(255);

update [dbo].[Nashville housing]
set OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'), 1);


select * from [dbo].[Nashville housing];

--change Y and N to Yes or No in SoldAsVacant

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from [dbo].[Nashville housing]
group by (SoldAsVacant)
order by 2;


select SoldAsVacant,
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [dbo].[Nashville housing]

use portofolioproject;

update [dbo].[Nashville housing]
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from [dbo].[Nashville housing]
group by (SoldAsVacant)
order by 2;

--remove duplicates

With RowNumCTE as(
select * ,
ROW_NUMBER() over(
   PARTITION BY ParcelID,
                PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				Order by UniqueID
				) row_num
from [dbo].[Nashville housing]
--order by ParcelID
)

delete
from  RowNumCTE
where row_num >1;


-- delete unused columns

Alter table [dbo].[Nashville housing]
drop column PropertyAddress, OwnerAddress, TaxDistrict;

Alter table [dbo].[Nashville housing]
drop column SaleDate;

select * 
from [dbo].[Nashville housing];