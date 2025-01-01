use eCommerceDb
------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_main_categories @token varchar(20)
as
begin
    set nocount on;
    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name from main_categories where status = 1 for json auto;
            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_main_category_by_id @token varchar(20),
                                                @main_category_id int
as
begin
    set nocount on;
    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name
            from main_categories
            where id = @main_category_id
              and status = 1
            for json auto, without_array_wrapper;

            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_categories @token varchar(20)
as
begin
    set nocount on;
    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name from categories where status = 1 for json auto;
            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_category_by_id @token varchar(20),
                                           @category_id int
as
begin
    set nocount on;

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name
            from categories
            where id = @category_id
              and status = 1
            for json auto, without_array_wrapper;
            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_sub_categories @token varchar(20)
as
begin
    set nocount on;
    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name from dbo.sub_categories where status = 1 for json auto;
            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_sub_category_by_id @token varchar(20),
                                               @sub_category_id int
as
begin
    set nocount on;

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id, name
            from sub_categories
            where id = @sub_category_id
              and status = 1
            for json auto, without_array_wrapper;
            return;
        end
    select dbo.fn_select_null_result();
end
go

------------------------------------------------------------------------------------------------------------------------

--когда юзер кликает по main_category

create procedure dbo.sp_get_categories_by_main_category @token varchar(20),
                                                        @main_category_id int
as
begin
    set nocount on;

    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            if exists(select 1
                      from dbo.main_category_sub_category_links mcscl
                               join dbo.categories c on mcscl.category_id = c.id
                      where mcscl.main_category_id = @main_category_id
                        and mcscl.status = 1
                        and c.status = 1)
                begin
                    -- Выбираем уникальные категории
                    select c.id   as category_id,
                           c.name as category_name
                    from dbo.main_category_sub_category_links mcscl
                             join dbo.categories c on mcscl.category_id = c.id
                    where mcscl.main_category_id = @main_category_id
                      and mcscl.status = 1
                      and c.status = 1
                    group by c.id, c.name -- Группировка для уникальности
                    for json path, include_null_values;
                end
            else
                begin
                    select null as category_id,
                           null as category_name
                    for json path, without_array_wrapper, include_null_values;
                end
        end
    else
        select dbo.fn_select_null_result();
end;
go

------------------------------------------------------------------------------------------------------------------------

--когда юзер наводится на main_category

create proc dbo.sp_get_categories_and_sub_categories_by_main_category @token varchar(20),
                                                                      @main_category_id int
as
begin
    set nocount on;

    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            if exists(select 1 from dbo.main_categories where id = @main_category_id and status = 1)
                begin
                    ;
                    with MainCategory as (select id as main_category_id, [name] as main_category_name
                                          from dbo.main_categories
                                          where id = @main_category_id)
                    select mc.main_category_id,
                           mc.main_category_name,
                           isnull(
                                   (select c.id   as category_id,
                                           c.name as category_name,
                                           isnull(
                                                   (select sc.id   as sub_category_id,
                                                           sc.name as sub_category_name
                                                    from dbo.main_category_sub_category_links mcscl
                                                             join dbo.sub_categories sc on mcscl.sub_category_id = sc.id
                                                    where mcscl.category_id = c.id
                                                      and mcscl.main_category_id = mc.main_category_id
                                                      and sc.status = 1
                                                    for json path), '[]'
                                           )      as sub_categories
                                    from dbo.main_category_sub_category_links mcscl
                                             join dbo.categories c on mcscl.category_id = c.id
                                    where mcscl.main_category_id = mc.main_category_id
                                      and c.status = 1
                                    group by c.id, c.name
                                    for json path), '[]'
                           ) as categories
                    from MainCategory mc
                    for json path, include_null_values;
                    return;
                end
            select dbo.fn_select_null_result();
        end
    select dbo.fn_select_null_result();
end;
go

------------------------------------------------------------------------------------------------------------------------

-- create proc sp_get_products @token varchar(20),
--                            @main_category_id int,
--                            @category_id int,
--                            @sub_category_id int = null,
--                            @clothing_gender_id dbo.gender_list readonly,
--                            @page_number int = 1,
--                            @page_size int = 15
-- as
-- begin
--     set nocount on;
--
--     declare @start_row int = (@page_number - 1) * @page_size + 1;
--     declare @end_row int = @page_number * @page_size;
--     declare @json_result nvarchar(max);
--
--     if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
--         begin
--             with ProductsCTE as (select p.product_id,
--                                         p.[name]                                                            as product_name,
--                                         p.clothing_gender_id,
--                                         mc.[name]                                                           as main_category_name,
--                                         c.[name]                                                            as category_name,
--                                         cg.[name]                                                           as gender_name,
--                                         (select count(*)
--                                          from dbo.product_variations pv
--                                          where pv.product_id = p.product_id)                                as colors,
--                                         pv_d.price,
--                                         IIF(pc.status = 1 and pc.start_date <= getdate() and
--                                             pc.end_date >= getdate(), pc.promo_code_id,
--                                             null)                                                           as promo_code,
--                                         coalesce(
--                                                 IIF(pc.status = 1 and pc.start_date <= getdate() and
--                                                     pc.end_date >= getdate(), pc.discount, null),
--                                                 0)                                                          as promo_discount,
--                                         (select top 1 pi.url
--                                          from dbo.product_images pi
--                                          where pi.product_variation_id = pv.variation_code
--                                            and pi.status = 1)                                               as ImageURL,
--                                         pv.variation_code,
--                                         row_number() over (partition by p.product_id order by p.product_id) as RowNum
--                                  from dbo.products p
--                                           inner join dbo.sub_categories sc on p.sub_category_id = sc.id
--                                           inner join dbo.categories c on sc.category_id = c.id
--                                           left join dbo.main_categories mc on p.main_category_id = mc.id
--                                           left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
--                                           inner join dbo.product_variations pv on pv.product_id = p.product_id
--                                           inner join dbo.product_variation_details pv_d
--                                                      on pv.variation_code = pv_d.product_variation_id
--                                           left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
--                                           left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
--                                  where sc.category_id = @category_id
--                                    and (p.sub_category_id = @sub_category_id or @sub_category_id is null)
--                                    and p.status = 1
--                                    and pv.status = 1
--                                    and exists (select 1
--                                                from dbo.inventory i
--                                                where i.product_variations_id = pv.variation_code
--                                                  and i.quantity > 0)
--                                    and (
--                                      (exists (select 1 from @clothing_gender_id) and
--                                       p.clothing_gender_id in (select value from @clothing_gender_id))
--                                          or
--                                      (not exists (select 1 from @clothing_gender_id) and
--                                       ((p.clothing_gender_id = 3 and @main_category_id in (11, 12)) or
--                                        p.main_category_id = @main_category_id))
--                                      ))
--             -- Оставляем только первую запись для каждого product_id и выбираем строки для текущей страницы
--             select @json_result = (select product_id,
--                                           product_name,
--                                           clothing_gender_id,
--                                           main_category_name,
--                                           category_name,
--                                           gender_name,
--                                           colors,
--                                           price,
--                                           promo_code,
--                                           promo_discount,
--                                           ImageURL        as Image,
--                                           (select variation_code,
--                                                   (select top 1 pi.url
--                                                    from dbo.product_images pi
--                                                    where pi.product_variation_id = pv.variation_code
--                                                      and pi.status = 1) as additional_image
--                                            from dbo.product_variations pv
--                                            where pv.product_id = ProductsCTE.product_id
--                                            for json path) as variations
--                                    from ProductsCTE
--                                    where RowNum = 1                             -- Оставляем только первую запись для каждого product_id
--                                      and RowNum between @start_row and @end_row -- Пагинация
--                                    for json auto, include_null_values);
--
--             if @json_result is null or @json_result = ''
--                 set @json_result = '[]';
--
--             select @json_result as json_result;
--         end
--     else
--         begin
--             select dbo.fn_select_null_result();
--         end
-- end;
-- go

------------------------------------------------------------------------------------------------------------------------

create proc sp_get_products @token VARCHAR(20),
                            @main_category_id INT,
                            @category_id INT,
                            @sub_category_id INT = NULL,
                            @clothing_gender_id dbo.gender_list READONLY,
                            @page_number INT = 1,
                            @page_size INT = 15,
                            @price_range_id INT = NULL,
                            @color_ids dbo.color_list READONLY,
                            @sort_type_id INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_row INT = (@page_number - 1) * @page_size + 1;
    DECLARE @end_row INT = @page_number * @page_size;
    DECLARE @json_result NVARCHAR(MAX);
    DECLARE @min_price DECIMAL(10, 2);
    DECLARE @max_price DECIMAL(10, 2);

    IF EXISTS (SELECT 1 FROM dbo.sessions WHERE token = @token AND status IN (1, 2))
        BEGIN
            IF @price_range_id IS NOT NULL
                BEGIN
                    SELECT @min_price = min_price, @max_price = max_price
                    FROM dbo.price_ranges
                    WHERE id = @price_range_id;
                END;

            WITH ProductsCTE AS (SELECT p.product_id,
                                        p.[name]                                                                 AS product_name,
                                        p.clothing_gender_id,
                                        mc.[name]                                                                AS main_category_name,
                                        c.[name]                                                                 AS category_name,
                                        cg.[name]                                                                AS gender_name,
                                        (SELECT COUNT(*)
                                         FROM dbo.product_variations pv
                                         WHERE pv.product_id = p.product_id)                                     AS colors,
                                        pv_d.price,
                                        p.update_date,
                                        IIF(pc.status = 1 AND pc.start_date <= GETDATE() AND pc.end_date >= GETDATE(),
                                            pc.promo_code_id,
                                            NULL)                                                                AS promo_code,
                                        COALESCE(IIF(pc.status = 1 AND pc.start_date <= GETDATE() AND
                                                     pc.end_date >= GETDATE(), pc.discount, NULL),
                                                 0)                                                              AS promo_discount,
                                        (SELECT TOP 1 pi.url
                                         FROM dbo.product_images pi
                                         WHERE pi.product_variation_id = pv.variation_code
                                           AND pi.status = 1)                                                    AS ImageURL,
                                        pv.variation_code,
                                        ROW_NUMBER() OVER (
                                            PARTITION BY p.product_id
                                            ORDER BY CASE WHEN @sort_type_id = 1 THEN p.update_date END DESC, -- newest
                                                CASE WHEN @sort_type_id = 2 THEN pv_d.price END DESC, -- high-low
                                                CASE WHEN @sort_type_id = 3 THEN pv_d.price END ASC -- low-high
                                            )                                                                    AS RowNum,
                                        ROW_NUMBER() OVER (PARTITION BY p.product_id ORDER BY pv.variation_code) AS VariationRowNum
                                 FROM dbo.products p
                                          INNER JOIN dbo.sub_categories sc ON p.sub_category_id = sc.id
                                          INNER JOIN dbo.categories c ON sc.category_id = c.id
                                          LEFT JOIN dbo.main_categories mc ON p.main_category_id = mc.id
                                          LEFT JOIN dbo.clothing_genders cg ON p.clothing_gender_id = cg.id
                                          INNER JOIN dbo.product_variations pv ON pv.product_id = p.product_id
                                          INNER JOIN dbo.product_variation_details pv_d
                                                     ON pv.variation_code = pv_d.product_variation_id
                                          LEFT JOIN dbo.product_discounts pd ON pd.product_variation_id = pv.variation_code
                                          LEFT JOIN dbo.promo_codes pc ON pd.promo_code_id = pc.promo_code_id
                                 WHERE sc.category_id = @category_id
                                   AND (p.sub_category_id = @sub_category_id OR @sub_category_id IS NULL)
                                   AND p.status = 1
                                   AND pv.status = 1
                                   AND EXISTS (SELECT 1
                                               FROM dbo.inventory i
                                               WHERE i.product_variations_id = pv.variation_code
                                                 AND i.quantity > 0)
                                   AND (
                                     (EXISTS (SELECT 1 FROM @clothing_gender_id) AND
                                      p.clothing_gender_id IN (SELECT value FROM @clothing_gender_id))
                                         OR (NOT EXISTS (SELECT 1 FROM @clothing_gender_id) AND
                                             ((p.clothing_gender_id = 3 AND @main_category_id IN (11, 12)) OR
                                              p.main_category_id = @main_category_id))
                                     )
                                   AND (@price_range_id IS NULL OR
                                        (pv_d.price >= @min_price AND (@max_price IS NULL OR pv_d.price <= @max_price)))
                                   AND (NOT EXISTS (SELECT 1 FROM @color_ids) OR
                                        pv_d.color_id IN (SELECT value FROM @color_ids)))

            SELECT @json_result = (SELECT product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          price,
                                          promo_code,
                                          promo_discount,
                                          ImageURL        AS Image,
                                          (SELECT variation_code,
                                                  additional_image = (SELECT TOP 1 pi.url
                                                                      FROM dbo.product_images pi
                                                                      WHERE pi.product_variation_id = pv.variation_code
                                                                        AND pi.status = 1)
                                           FROM dbo.product_variations pv
                                           WHERE pv.product_id = ProductsCTE.product_id
                                             AND VariationRowNum = 1
                                           FOR JSON PATH) AS variations
                                   FROM ProductsCTE
                                   WHERE RowNum BETWEEN @start_row AND @end_row
                                     AND VariationRowNum = 1
                                   ORDER BY CASE WHEN @sort_type_id = 1 THEN update_date END DESC,
                                            CASE WHEN @sort_type_id = 2 THEN price END DESC,
                                            CASE WHEN @sort_type_id = 3 THEN price END ASC
                                   FOR JSON AUTO, INCLUDE_NULL_VALUES);

            IF @json_result IS NULL OR @json_result = ''
                SET @json_result = '[]';

            SELECT @json_result AS json_result;
        END
    ELSE
        BEGIN
            SELECT dbo.fn_select_null_result();
        END
END;
GO

------------------------------------------------------------------------------------------------------------------------

create proc sp_get_product_preview @token varchar(20),
                                   @variation_code varchar(6)
as
begin
    set nocount on;

    declare @json_result nvarchar(max);

    -- Проверка токена пользователя
    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            with ProductDetailsCTE as (select p.product_id,
                                              p.[name]                                              as product_name,
                                              p.clothing_gender_id,
                                              mc.[name]                                             as main_category_name,
                                              c.[name]                                              as category_name,
                                              cg.[name]                                             as gender_name,
                                              (select count(*)
                                               from dbo.product_variations pv
                                               where pv.product_id = p.product_id)                  as colors,
                                              pv_d.price,
                                              IIF(pc.status = 1 and pc.start_date <= getdate() and
                                                  pc.end_date >= getdate(), pc.promo_code_id, null) as promo_code,
                                              coalesce(
                                                      IIF(pc.status = 1 and pc.start_date <= getdate() and
                                                          pc.end_date >= getdate(), pc.discount, null),
                                                      0
                                              )                                                     as promo_discount,
                                              (select top 1 pi.url
                                               from dbo.product_images pi
                                               where pi.product_variation_id = pv.variation_code
                                                 and pi.status = 1)                                 as ImageURL
                                       from dbo.products p
                                                inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                                inner join dbo.categories c on sc.category_id = c.id
                                                left join dbo.main_categories mc on p.main_category_id = mc.id
                                                left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                                inner join dbo.product_variations pv on pv.product_id = p.product_id
                                                inner join dbo.product_variation_details pv_d
                                                           on pv.variation_code = pv_d.product_variation_id
                                                left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                                left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                       where pv.variation_code = @variation_code
                                         and p.status = 1
                                         and pv.status = 1)

            -- Формирование JSON-результата с вариациями
            select @json_result = (select product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          price,
                                          promo_code,
                                          promo_discount,
                                          ImageURL        as Image,
                                          (select variation_code,
                                                  (select top 1 pi.url
                                                   from dbo.product_images pi
                                                   where pi.product_variation_id = pv.variation_code
                                                     and pi.status = 1) as additional_image
                                           from dbo.product_variations pv
                                           where pv.product_id = ProductDetailsCTE.product_id
                                           for json path) as variations
                                   from ProductDetailsCTE
                                   for json auto, include_null_values,without_array_wrapper);

            -- Если результат пуст, вернуть пустой массив
            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as json_result;
        end
    else
        begin
            select dbo.fn_select_null_result();
        end
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_sub_categories_by_filter @token varchar(20),
                                                @main_category_id int = null,
                                                @category_id int,
                                                @clothing_gender_ids dbo.gender_list readonly
as
begin
    set nocount on;
    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select distinct sc.id   as sub_category_id,
                            sc.name as sub_category_name
            from dbo.products p
                     join dbo.sub_categories sc on p.sub_category_id = sc.id
            where sc.category_id = @category_id
              and sc.status = 1
              and (
                exists (select 1 from @clothing_gender_ids)
                    and p.clothing_gender_id in (select value from @clothing_gender_ids)
                    or
                not exists (select 1 from @clothing_gender_ids)
                    and p.main_category_id = @main_category_id
                )
            order by sc.name
            for json path , root('sub_categories');
            return;
        end
    select dbo.fn_select_null_result();
end;
go;

------------------------------------------------------------------------------------------------------------------------

create proc sp_get_genders_by_filter @token varchar(20)
as
begin
    set nocount on;
    if exists(select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            select id,
                   name
            from dbo.clothing_genders
            where status = 1 -- только активные записи
            for json auto, include_null_values;
            return;
        end
    select dbo.fn_select_null_result();
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc sp_select_product_info @token varchar(20),
                                   @variation_code varchar(6)
as
begin
    set nocount on;

    declare @json_result nvarchar(max);

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            with ProductDetailsCTE as (select p.product_id,
                                              p.[name]                                              as product_name,
                                              p.clothing_gender_id,
                                              mc.[name]                                             as main_category_name,
                                              c.[name]                                              as category_name,
                                              cg.[name]                                             as gender_name,
                                              (select count(*)
                                               from dbo.product_variations pv
                                               where pv.product_id = p.product_id)                  as colors,
                                              pv_d.price,
                                              IIF(pc.status = 1 and pc.start_date <= getdate() and
                                                  pc.end_date >= getdate(), pc.promo_code_id, null) as promo_code,
                                              coalesce(
                                                      IIF(pc.status = 1 and pc.start_date <= getdate() and
                                                          pc.end_date >= getdate(), pc.discount, null),
                                                      0
                                              )                                                     as promo_discount,
                                              pv_d.description,
                                              clr.name                                              as color_name,
                                              (select count(*)
                                               from dbo.reviews r
                                               where r.product_id = pv.variation_code)              as review_count,
                                              (select AVG(r.rating)
                                               from dbo.reviews r
                                               where r.product_id = pv.variation_code)              as average_rating

                                       from dbo.products p
                                                inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                                inner join dbo.categories c on sc.category_id = c.id
                                                left join dbo.main_categories mc on p.main_category_id = mc.id
                                                left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                                inner join dbo.product_variations pv on pv.product_id = p.product_id
                                                inner join dbo.product_variation_details pv_d
                                                           on pv.variation_code = pv_d.product_variation_id
                                                left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                                left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                                left join dbo.clothing_colors clr on pv_d.color_id = clr.code
                                       where pv.variation_code = @variation_code
                                         and p.status = 1
                                         and pv.status = 1)

            select @json_result = (select product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          price,
                                          promo_code,
                                          promo_discount,
                                          description,
                                          color_name,
                                          review_count,
                                          average_rating,
                                          (select url
                                           from dbo.product_images
                                           where product_variation_id = @variation_code
                                             and status = 1
                                           for json path) as images,
                                          (select size
                                           from dbo.product_variation_sizes pvs
                                                    inner join dbo.sizes s on pvs.size_id = s.size
                                           where pvs.product_variation_id = @variation_code
                                             and pvs.status = 1
                                           for json path) as available_sizes,
                                          (select pv.variation_code,
                                                  coalesce(
                                                          (select top 1 pi.url
                                                           from dbo.product_images pi
                                                           where pi.product_variation_id = pv.variation_code
                                                             and pi.status = 1),
                                                          ''
                                                  ) as additional_image
                                           from dbo.product_variations pv
                                           where pv.product_id = ProductDetailsCTE.product_id
                                           for json path) as variations
                                   from ProductDetailsCTE
                                   for json auto, include_null_values,without_array_wrapper);

            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as json_result;
        end
    else
        begin
            select dbo.fn_select_null_result();
        end
end;
go

------------------------------------------------------------------------------------------------------------------------

create PROC dbo.sp_get_product_reviews @token VARCHAR(20),
                                       @variation_code VARCHAR(6),
                                       @page INT = 1,
                                       @page_size INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @json_result NVARCHAR(MAX);
    DECLARE @total_reviews INT;

    IF EXISTS(SELECT 1 FROM dbo.sessions WHERE token = @token AND status IN (1, 2))
        BEGIN
            SELECT @total_reviews = COUNT(*)
            FROM dbo.reviews r
            WHERE r.product_id = @variation_code;

            SELECT @json_result = (SELECT @total_reviews                       AS total_reviews,
                                          (SELECT u.name         AS reviewer_name,
                                                  r.rating       AS stars,
                                                  r.comment      AS review_comment,
                                                  r.updated_date AS review_date
                                           FROM dbo.reviews r
                                                    INNER JOIN dbo.user_accounts u ON r.user_id = u.user_id
                                           WHERE r.product_id = @variation_code
                                           ORDER BY r.updated_date DESC
                                           OFFSET (@page - 1) * @page_size ROWS FETCH NEXT @page_size ROWS ONLY
                                           FOR JSON PATH, INCLUDE_NULL_VALUES) AS reviews
                                   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            IF @json_result IS NULL OR @json_result = ''
                SET @json_result = '{"total_reviews": 0, "reviews": []}';

            SELECT @json_result AS json_result;
            RETURN;
        END

    SELECT 'null' AS json_result;
END;
GO

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_add_or_update_review @token varchar(20),
                                             @product_variation_id varchar(6),
                                             @rating int,
                                             @comment varchar(150) = null,
                                             @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status in (1, 2));

    if exists (select 1 from dbo.user_accounts where user_id = @user_id)
        and exists (select 1 from dbo.product_variation_details where product_variation_id = @product_variation_id)
        begin
            if exists (select 1 from dbo.reviews where user_id = @user_id and product_id = @product_variation_id)
                begin
                    update dbo.reviews
                    set rating       = @rating,
                        comment      = @comment,
                        updated_date = getutcdate()
                    where user_id = @user_id
                      and product_id = @product_variation_id;
                    set @sql_result = 1;
                end
            else
                begin
                    insert into dbo.reviews (user_id, product_id, rating, comment)
                    values (@user_id, @product_variation_id, @rating, @comment);
                    set @sql_result = 1;
                end
        end
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_toggle_favorite @token varchar(20),
                                   @variation_code varchar(6),
                                   @sql_result bit output
as
begin
    set nocount on;

    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status in (1, 2));

    if @user_id is null
        return ;

    if not exists(select 1 from dbo.product_variations where variation_code = @variation_code)
        return;

    if exists (select 1 from dbo.favorites where user_id = @user_id and product_variation_id = @variation_code)
        begin

            declare @is_favorite bit = IIF(
                    (select [is_favorite]
                     from dbo.favorites
                     where product_variation_id = @variation_code
                       and user_id = @user_id) = 1,
                    0,
                    1);

            update dbo.favorites
            set is_favorite = @is_favorite,
                update_date = getutcdate()
            where product_variation_id = @variation_code
              and user_id = @user_id;

            set @sql_result = 1;
        end
    else
        begin
            insert into dbo.favorites (user_id, product_variation_id)
            values (@user_id, @variation_code);

            set @sql_result = 1;
        end

end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_favorites @token varchar(20),
                                 @page_number int = 1,
                                 @page_size int = 10
as
begin
    set nocount on;

    declare @json_result nvarchar(max);
    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status in (1, 2));

    if @user_id is null
        begin
            select dbo.fn_select_null_result();
            return;
        end;

    declare @start_row int = (@page_number - 1) * @page_size + 1;
    declare @end_row int = @page_number * @page_size;

    -- cte для извлечения информации об избранных продуктах с использованием row_number() для пагинации
    with favoriteproductscte as (select row_number() over (order by p.product_id)                     as row_num,
                                        p.product_id,
                                        p.[name]                                                      as product_name,
                                        p.clothing_gender_id,
                                        mc.[name]                                                     as main_category_name,
                                        c.[name]                                                      as category_name,
                                        cg.[name]                                                     as gender_name,
                                        pv_d.price,
                                        iif(pc.status = 1 and pc.start_date <= getdate() and pc.end_date >= getdate(),
                                            pc.promo_code_id, null)                                   as promo_code,
                                        coalesce(iif(pc.status = 1 and pc.start_date <= getdate() and
                                                     pc.end_date >= getdate(), pc.discount, null), 0) as promo_discount,
                                        (select top 1 pi.url
                                         from dbo.product_images pi
                                         where pi.product_variation_id = f.product_variation_id
                                           and pi.status = 1)                                         as image
                                 from dbo.favorites f
                                          inner join dbo.product_variations pv on f.product_variation_id = pv.variation_code
                                          inner join dbo.products p on pv.product_id = p.product_id
                                          inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                          inner join dbo.categories c on sc.category_id = c.id
                                          left join dbo.main_categories mc on p.main_category_id = mc.id
                                          left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                          inner join dbo.product_variation_details pv_d
                                                     on pv.variation_code = pv_d.product_variation_id
                                          left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                          left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                 where f.user_id = @user_id
                                   and f.is_favorite = 1
                                   and p.status = 1
                                   and pv.status = 1)

    -- формирование json-результата с учетом пагинации
    select @json_result = (select product_id,
                                  product_name,
                                  clothing_gender_id,
                                  main_category_name,
                                  category_name,
                                  gender_name,
                                  price,
                                  promo_code,
                                  promo_discount,
                                  image
                           from favoriteproductscte
                           where row_num between @start_row and @end_row
                           for json auto, include_null_values);

    if @json_result is null or @json_result = ''
        set @json_result = '[]';

    select @json_result as json_result;
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_select_available_sizes @token varchar(20),
                                          @variation_code varchar(6)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status in (1, 2));

    if @user_id is null
        return;

    declare @json_result nvarchar(max);

    if exists (select 1 from dbo.product_variations where variation_code = @variation_code and status = 1)
        begin
            select @json_result = (select s.id, s.size
                                   from dbo.product_variation_sizes pvs
                                            inner join dbo.sizes s on pvs.size_id = s.id
                                   where pvs.product_variation_id = @variation_code
                                     and pvs.status = 1
                                   for json auto);

            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as available_sizes;
            return;
        end
    else
        begin
            set @json_result = '[]';
            select @json_result as available_sizes;
        end
end;
go

exec dbo.sp_select_available_sizes '17376f11b261aa802c01', '801333'

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_countries @token varchar(20)
as
begin
    set nocount on;

    select JSON_QUERY((select location_id as id,
                              name        as country_name
                       from dbo.locations
                       where type = 'Country'
                       for json path)) as result_json;
end;
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_locations_by_country @token varchar(20),
                                            @country_id varchar(6)
as
begin
    set nocount on;

    select JSON_QUERY((select l.location_id as location_id,
                              l.name        as location_name,
                              l.type        as location_type
                       from dbo.locations l
                       where l.parent_id = @country_id
                       for json path)) as result_json;
end;
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_get_all_countries_and_regions @token varchar(20)
as
begin
    set nocount on;

    select JSON_QUERY((select c.name          as country_name,
                              'Country'       as location_type,
                              (select l.name   as region_name,
                                      'Region' as region_type
                               from dbo.locations l
                               where l.parent_id = c.location_id
                               for json path) as regions
                       from dbo.locations c
                       where c.type = 'Country'
                       for json path)) as result_json;
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_select_user_info @token varchar(20)
as
begin
    set nocount on;
    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    select ua.email,
           '••••••••••••••••' as password,
           uac.phone_number,
           uac.birth_date,
           country.name       as [Country/Region],
           case
               when province.type in ('State', 'Region') then province.name
               end            as State,
           case
               when province.type = 'Province'
                   and not exists (select 1
                                   from dbo.locations
                                   where location_id = uac.location_id
                                     and type in ('State', 'Region'))
                   then province.name
               end            as Province,
           uac.city           as City,
           uac.zip_code       as Postcode
    from dbo.user_accounts ua
             left join dbo.user_accounts_clients uac on ua.user_id = uac.user_id
             left join dbo.locations country on uac.country_id = country.location_id and country.type = 'Country'
             left join dbo.locations province
                       on uac.location_id = province.location_id and province.type in ('State', 'Province', 'Region')
    where ua.user_id = @user_id
      and ua.user_status_id = 1
    for json path , without_array_wrapper,include_null_values;
end;
go;

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_update_user @token varchar(20),
                                    @new_email varchar(255),
                                    @phone_number varchar(12),
                                    @new_country_id varchar(6),
                                    @new_location_id varchar(6),
                                    @new_city varchar(100),
                                    @new_zip_code varchar(5),
                                    @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0
    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @affected_rows int = 0;

    set @affected_rows = @affected_rows + @@rowcount;

    update dbo.user_accounts
    set email = @new_email
    where user_id = @user_id;

    update dbo.user_accounts_clients
    set country_id  = @new_country_id,
        phone_number=@phone_number,
        location_id = @new_location_id,
        city        = @new_city,
        zip_code    = @new_zip_code
    where user_id = @user_id;

    set @affected_rows = @affected_rows + @@rowcount;

    if @@rowcount > 0
        set @sql_result = 1
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_change_password @token varchar(20),
                                        @new_password varchar(100),
                                        @code int output
as
begin
    set nocount on;
    set @code = 500;

    declare @user_id varchar(12) = (select user_id
                                    from dbo.sessions
                                    where token = @token
                                      and status = 1);

    if @user_id is null
        begin
            set @code = 401; -- Unauthorized
            return;
        end

    declare @role_id int = (select role_id
                            from dbo.user_roles
                            where user_id = @user_id);

    if @role_id = 1
        begin
            set @code = 403; -- Forbidden
            return;
        end

    update dbo.user_accounts
    set password_hash = @new_password
    where user_id = @user_id;

    if @@rowcount = 1
        begin
            declare @new_token varchar(20) = lower(convert(varchar(20), crypt_gen_random(10), 2));

            update dbo.sessions
            set token       = @new_token,
                update_date = getutcdate()
            where token = @token;

            update dbo.sessions
            set status      = 0,
                update_date = getutcdate(),
                logout_date = getutcdate()
            where user_id = @user_id
              and token != @new_token;

            if @@rowcount >= 0
                set @code = 200;
        end
    else
        begin
            set @code = 500; -- Internal Server Error
        end
end;
go


------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_stored_password @token varchar(20)
as
begin
    set nocount on;

    select ua.password_hash
    from dbo.user_accounts ua
             join dbo.sessions s on ua.user_id = s.user_id
    where s.token = @token
      and s.status = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_add_user_addresses @token varchar(20),
                                      @first_name varchar(50),
                                      @last_name varchar(50),
                                      @street_address nvarchar(50),
                                      @street_address_second nvarchar(50) = NULL,
                                      @country_id varchar(6),
                                      @location_id varchar(6),
                                      @city varchar(50),
                                      @zip_code varchar(5),
                                      @phone_number varchar(20),
                                      @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        begin
            return;
        end

    if exists (select 1
               from dbo.addresses a
                        join dbo.user_addresses ua on a.address_id = ua.address_id
               where ua.user_id = @user_id
                 and a.street_address = @street_address
                 and a.city = @city
                 and a.zip_code = @zip_code
                 and a.country_id = @country_id)
        begin
            return ;
        end

    insert into dbo.addresses (first_name, last_name, street_address, street_address_second, country_id, location_id,
                               city, zip_code, phone_number)
    values (@first_name, @last_name, @street_address, @street_address_second, @country_id, @location_id, @city,
            @zip_code, @phone_number);

    declare @address_id varchar(12)=(select address_id from dbo.addresses where id = scope_identity());

    insert into dbo.user_addresses (user_id, address_id)
    values (@user_id, @address_id);

    if @@rowcount = 1
        set @sql_result = 1;
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.get_user_addresses @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        begin
            return;
        end

    if exists (select 1 from dbo.user_addresses where user_id = @user_id)
        begin
            select a.address_id,
                   a.first_name,
                   a.last_name,
                   a.street_address,
                   a.street_address_second,
                   a.country_id,
                   a.location_id,
                   a.city,
                   a.zip_code,
                   a.phone_number
            from dbo.addresses a
                     inner join
                 dbo.user_addresses ua on a.address_id = ua.address_id
            where ua.user_id = @user_id
              and ua.status = 1
              and a.status = 1
            for json path;
            return;
        end
    select 'null';
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_user_address @token varchar(20),
                                       @address_id varchar(12),
                                       @first_name varchar(50),
                                       @last_name varchar(50),
                                       @street_address varchar(50),
                                       @street_address_second varchar(50) = NULL,
                                       @country_id varchar(6),
                                       @location_id varchar(6),
                                       @city varchar(50),
                                       @zip_code varchar(5),
                                       @phone_number varchar(20),
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    if exists (select 1 from dbo.user_addresses where user_id = @user_id and address_id = @address_id)
        begin
            update dbo.addresses
            set first_name            = @first_name,
                last_name             = @last_name,
                street_address        = @street_address,
                street_address_second = @street_address_second,
                country_id            = @country_id,
                location_id           = @location_id,
                city                  = @city,
                zip_code              = @zip_code,
                phone_number          = @phone_number,
                update_date           = getutcdate()
            where address_id = @address_id;

            if @@rowcount = 1
                set @sql_result = 1;
        end
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_delete_user_address @token varchar(20),
                                       @address_id varchar(12),
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    if exists (select 1 from dbo.user_addresses where user_id = @user_id and address_id = @address_id)
        begin
            update dbo.user_addresses
            set status=0,
                update_date=getutcdate()
            where user_id = @user_id
              and address_id = @address_id;

            if @@rowcount = 1
                set @sql_result = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

alter proc dbo.add_user_bank_card @token varchar(20),
                                  @card_number varchar(16),
                                  @card_holder_name varchar(50),
                                  @card_holder_surname varchar(50),
                                  @expiration_date varchar(5),
                                  @cvv VARCHAR(3),
                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    if exists (select 1 from dbo.bank_cards where card_number = @card_number)
        return;

    insert into dbo.bank_cards (card_number, card_holder_name, card_holder_surname, expiration_date, cvv)
    values (@card_number, @card_holder_name, @card_holder_surname, @expiration_date, @Cvv);

    declare @bank_card_id varchar(6)=(select bank_card_id from dbo.bank_cards where id = scope_identity());

    insert into dbo.user_bank_cards (user_id, bank_carts_id)
    values (@user_id, @bank_card_id);

    if @@rowcount = 1
        set @sql_result = 1;
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.get_user_bank_cards @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @card_data nvarchar(max);

    select @card_data =
           isnull((select bank_card_id,
                          card_number = '**** **** **** ' + right(card_number, 4),
                          expiration_date
                   from dbo.user_bank_cards ubc
                            join dbo.bank_cards bc on ubc.bank_carts_id = bc.bank_card_id
                   where ubc.user_id = @user_id
                     and ubc.status = 1
                     and bc.status = 1
                   for json auto), 'null');

    select @card_data as result;
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.update_user_bank_card @token varchar(20),
                                      @bank_card_id varchar(6),
                                      @card_number varchar(16),
                                      @card_holder_name varchar(50),
                                      @card_holder_surname varchar(50),
                                      @expiration_date varchar(5),
                                      @cvv varchar(3),
                                      @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    if exists (select 1 from dbo.user_bank_cards where user_id = @user_id and bank_carts_id = @bank_card_id)
        begin
            update dbo.bank_cards
            set card_number         = @card_number,
                card_holder_name    = @card_holder_name,
                card_holder_surname = @card_holder_surname,
                expiration_date     = @expiration_date,
                cvv                 = @cvv
            where bank_card_id = @bank_card_id;

            if @@rowcount = 1
                set @sql_result = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.delete_user_bank_card @token varchar(20),
                                      @bank_card_id varchar(6),
                                      @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        begin
            return;
        end

    if exists (select 1 from dbo.user_bank_cards where user_id = @user_id and bank_carts_id = @bank_card_id)
        begin
            update dbo.user_bank_cards
            set status=0,
                update_date=getutcdate()
            where bank_carts_id = @bank_card_id
              and user_id = @user_id
              and status = 1

            if @@rowcount = 1
                set @sql_result = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

/*
alter procedure dbo.sp_search @token varchar(20),
                              @main_category_id int = null,
                              @category_id int = null,
                              @sub_category_id int = null,
                              @fabric varchar(25) = null,
                              @keyword nvarchar(200) = null
as
begin
    set nocount on;

    declare @json_result nvarchar(max);

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            with productdetailscte as (select p.product_id,
                                              p.[name]                             as product_name,
                                              p.clothing_gender_id,
                                              mc.[name]                            as main_category_name,
                                              c.[name]                             as category_name,
                                              cg.[name]                            as gender_name,
                                              (select count(*)
                                               from dbo.product_variations pv
                                               where pv.product_id = p.product_id) as colors,
                                              pv_d.price,
                                              iif(pc.status = 1 and pc.start_date <= getdate() and
                                                  pc.end_date >= getdate(), pc.promo_code_id,
                                                  null)                            as promo_code,
                                              coalesce(iif(pc.status = 1 and pc.start_date <= getdate() and
                                                           pc.end_date >= getdate(), pc.discount, null),
                                                       0)                          as promo_discount,
                                              (select top 1 pi.url
                                               from dbo.product_images pi
                                               where pi.product_variation_id = pv.variation_code
                                                 and pi.status = 1)                as imageurl
                                       from dbo.products p
                                                inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                                inner join dbo.categories c on sc.category_id = c.id
                                                left join dbo.main_categories mc on p.main_category_id = mc.id
                                                left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                                inner join dbo.product_variations pv on pv.product_id = p.product_id
                                                inner join dbo.product_variation_details pv_d
                                                           on pv.variation_code = pv_d.product_variation_id
                                                left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                                left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                       where (@main_category_id is null or p.main_category_id = @main_category_id)
                                         and (@category_id is null or exists (select 1
                                                                              from dbo.main_category_sub_category_links as links
                                                                              where links.main_category_id = @main_category_id
                                                                                and links.category_id = @category_id
                                                                                and links.sub_category_id = p.sub_category_id))
                                         and (@sub_category_id is null or p.sub_category_id = @sub_category_id)
                                         and (@fabric is null or pv_d.fabric = @fabric)
                                         and (@keyword is null or pv_d.description like '%' + @keyword + '%'))

            select @json_result = (select product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          price,
                                          promo_code,
                                          promo_discount,
                                          imageurl        as image,
                                          (select variation_code,
                                                  (select top 1 pi.url
                                                   from dbo.product_images pi
                                                   where pi.product_variation_id = pv.variation_code
                                                     and pi.status = 1) as additional_image
                                           from dbo.product_variations pv
                                           where pv.product_id = productdetailscte.product_id
                                           for json path) as variations
                                   from productdetailscte
                                   for json path, include_null_values);

            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as json_result;
        end
    else
        begin
            select dbo.fn_select_null_result();
        end
end;
go
*/

/*
create procedure dbo.sp_search @token varchar(20),
                               @main_category_id int = null,
                               @category_id int = null,
                               @sub_category_id int = null,
                               @fabric varchar(25) = null,
                               @keyword nvarchar(200) = null,
                               @product_name nvarchar(100) = null
as
begin
    set nocount on;

    declare @json_result nvarchar(max);

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            with productdetailscte as (select p.product_id,
                                              p.[name]                             as product_name,
                                              p.clothing_gender_id,
                                              mc.[name]                            as main_category_name,
                                              c.[name]                             as category_name,
                                              cg.[name]                            as gender_name,
                                              (select count(*)
                                               from dbo.product_variations pv
                                               where pv.product_id = p.product_id) as colors,
                                              pv_d.price,
                                              iif(pc.status = 1 and pc.start_date <= getdate() and
                                                  pc.end_date >= getdate(), pc.promo_code_id,
                                                  null)                            as promo_code,
                                              coalesce(iif(pc.status = 1 and pc.start_date <= getdate() and
                                                           pc.end_date >= getdate(), pc.discount, null),
                                                       0)                          as promo_discount,
                                              (select top 1 pi.url
                                               from dbo.product_images pi
                                               where pi.product_variation_id = pv.variation_code
                                                 and pi.status = 1)                as imageurl
                                       from dbo.products p
                                                inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                                inner join dbo.categories c on sc.category_id = c.id
                                                left join dbo.main_categories mc on p.main_category_id = mc.id
                                                left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                                inner join dbo.product_variations pv on pv.product_id = p.product_id
                                                inner join dbo.product_variation_details pv_d
                                                           on pv.variation_code = pv_d.product_variation_id
                                                left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                                left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                       where (@main_category_id is null or p.main_category_id = @main_category_id)
                                         and (@category_id is null or exists (select 1
                                                                              from dbo.main_category_sub_category_links as links
                                                                              where links.main_category_id = @main_category_id
                                                                                and links.category_id = @category_id
                                                                                and links.sub_category_id = p.sub_category_id))
                                         and (@sub_category_id is null or p.sub_category_id = @sub_category_id)
                                         and (@fabric is null or pv_d.fabric like @fabric + '%')
                                         and (@keyword is null or pv_d.description like '%' + @keyword + '%')
                                         and (@product_name is null or
                                              p.[name] like '%' + ltrim(rtrim(@product_name)) + '%'))
            select @json_result = (select product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          price,
                                          promo_code,
                                          promo_discount,
                                          imageurl as image,
                                          JSON_QUERY(
                                                  (select pv.variation_code,
                                                          (select top 1 pi.url
                                                           from dbo.product_images pi
                                                           where pi.product_variation_id = pv.variation_code
                                                             and pi.status = 1) as additional_image
                                                   from dbo.product_variations pv
                                                   where pv.product_id = productdetailscte.product_id
                                                   for json path, include_null_values)
                                          )        as variations
                                   from productdetailscte
                                   for json path, include_null_values);

            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as json_result;
        end
    else
        begin
            select dbo.fn_select_null_result();
        end
end;
go
*/

create procedure dbo.sp_search @token varchar(20),
                               @main_category_id int = null,
                               @category_id int = null,
                               @sub_category_id int = null,
                               @fabric varchar(25) = null,
                               @keyword nvarchar(200) = null,
                               @product_name nvarchar(100) = null
as
begin
    set nocount on;

    declare @json_result nvarchar(max);

    if exists (select 1 from dbo.sessions where token = @token and status in (1, 2))
        begin
            ;
            with productdetailscte as (select p.product_id,
                                              p.[name]                                                                  as product_name,
                                              p.clothing_gender_id,
                                              mc.[name]                                                                 as main_category_name,
                                              c.[name]                                                                  as category_name,
                                              cg.[name]                                                                 as gender_name,
                                              (select count(*)
                                               from dbo.product_variations pv
                                               where pv.product_id = p.product_id)                                      as colors,
                                              pv.variation_code,
                                              pv_d.price,
                                              iif(pc.status = 1 and pc.start_date <= getdate() and
                                                  pc.end_date >= getdate(), pc.promo_code_id,
                                                  null)                                                                 as promo_code,
                                              coalesce(iif(pc.status = 1 and pc.start_date <= getdate() and
                                                           pc.end_date >= getdate(), pc.discount, null),
                                                       0)                                                               as promo_discount,
                                              (select top 1 pi.url
                                               from dbo.product_images pi
                                               where pi.product_variation_id = pv.variation_code
                                                 and pi.status = 1)                                                     as imageurl,
                                              row_number() over (partition by p.product_id order by pv.update_date asc) as rn
                                       from dbo.products p
                                                inner join dbo.sub_categories sc on p.sub_category_id = sc.id
                                                inner join dbo.categories c on sc.category_id = c.id
                                                left join dbo.main_categories mc on p.main_category_id = mc.id
                                                left join dbo.clothing_genders cg on p.clothing_gender_id = cg.id
                                                inner join dbo.product_variations pv on pv.product_id = p.product_id
                                                inner join dbo.product_variation_details pv_d
                                                           on pv.variation_code = pv_d.product_variation_id
                                                left join dbo.product_discounts pd on pd.product_variation_id = pv.variation_code
                                                left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
                                       where (@main_category_id is null or p.main_category_id = @main_category_id)
                                         and (@category_id is null or exists (select 1
                                                                              from dbo.main_category_sub_category_links as links
                                                                              where links.main_category_id = @main_category_id
                                                                                and links.category_id = @category_id
                                                                                and links.sub_category_id = p.sub_category_id))
                                         and (@sub_category_id is null or p.sub_category_id = @sub_category_id)
                                         and (@fabric is null or pv_d.fabric like @fabric + '%')
                                         and (@keyword is null or pv_d.description like '%' + @keyword + '%')
                                         and (@product_name is null or
                                              p.[name] like '%' + ltrim(rtrim(@product_name)) + '%'))
            select @json_result = (select product_id,
                                          product_name,
                                          clothing_gender_id,
                                          main_category_name,
                                          category_name,
                                          gender_name,
                                          colors,
                                          max(price) as price,
                                          promo_code,
                                          promo_discount,
                                          null       as Image,
                                          JSON_QUERY(
                                                  (select variation_code,
                                                          imageurl as additional_image
                                                   from productdetailscte as variations
                                                   where variations.product_id = p.product_id
                                                   for json path, include_null_values)
                                          )          as variations
                                   from productdetailscte p
                                   where rn = 1
                                   group by product_id, product_name, clothing_gender_id, main_category_name,
                                            category_name, gender_name, colors, promo_code, promo_discount
                                   for json path, include_null_values);

            if @json_result is null or @json_result = ''
                set @json_result = '[]';

            select @json_result as json_result;
        end
    else
        begin
            select dbo.fn_select_null_result();
        end
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.add_to_cart @token varchar(20),
                                 @variation_code varchar(6),
                                 @size_id varchar(5),
                                 @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @available_quantity int;
    select @available_quantity = i.quantity
    from dbo.inventory i
             join dbo.product_variation_sizes pvs on i.product_variations_id = pvs.product_variation_id
    where i.product_variations_id = @variation_code
      and pvs.size_id = @size_id;

    if @available_quantity is null or @available_quantity <= 0
        return;

    declare @cart_id varchar(12);
    select @cart_id = c.cart_id
    from dbo.carts c
    where c.user_id = @user_id;

    if @cart_id is null
        begin
            insert into dbo.carts (user_id)
            values (@user_id);

            set @cart_id = (select cart_id from dbo.carts where id = scope_identity());
        end

    if exists (select 1
               from dbo.cart_items
               where cart_id = @cart_id
                 and product_id = @variation_code
                 and size_id = @size_id)
        begin
            update dbo.cart_items
            set quantity = quantity + 1
            where cart_id = @cart_id
              and product_id = @variation_code
              and size_id = @size_id;
        end
    else
        begin
            insert into dbo.cart_items (cart_id, product_id, size_id, quantity, price)
            select @cart_id, @variation_code, @size_id, 1, pvd.price
            from dbo.product_variation_details pvd
            where pvd.product_variation_id = @variation_code;
        end

    set @sql_result = 1;
end;
go;

------------------------------------------------------------------------------------------------------------------------

/*
alter procedure dbo.view_cart @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @cart_id varchar(12);
    select @cart_id = c.cart_id
    from dbo.carts c
    where c.user_id = @user_id;

    if @cart_id is null
        return;

    select pvd.product_variation_id,
           p.[name]    as product_name,
           mc.[name]   as main_category,
           cc.[name]   as color,
           s.size,
           ci.quantity,
           ci.price,
           pi.image_id as first_image
    from dbo.cart_items ci
             join dbo.product_variation_details pvd on ci.product_id = pvd.product_variation_id
             join dbo.products p on pvd.product_variation_id = p.product_id
             join dbo.main_categories mc on p.main_category_id = mc.id
             join dbo.clothing_colors cc on pvd.color_id = cc.code
             join dbo.sizes s on ci.size_id = s.size
             join dbo.product_images pi on pi.product_variation_id = pvd.product_variation_id
    where ci.cart_id = @cart_id
      and pi.image_id = 'thumbnail'
    for json auto;
end;
go;
*/

create procedure dbo.view_cart @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @cart_id varchar(12);
    select @cart_id = c.cart_id
    from dbo.carts c
    where c.user_id = @user_id;

    if @cart_id is null
        return;

    select ci.cart_item_id,
           pvd.product_variation_id,
           p.[name]  as product_name,
           mc.[name] as main_category,
           cc.[name] as color,
           s.size,
           ci.quantity,
           ci.price,
           pi.first_image,
           ci.is_selected
    from dbo.cart_items ci
             join dbo.product_variation_details pvd on ci.product_id = pvd.product_variation_id
             join dbo.product_variations pv on pvd.product_variation_id = pv.variation_code
             join dbo.products p on pv.product_id = p.product_id
             join dbo.main_categories mc on p.main_category_id = mc.id
             join dbo.clothing_colors cc on pvd.color_id = cc.code
             join dbo.sizes s on ci.size_id = s.id
             left join (select pi.product_variation_id,
                               pi.url as first_image
                        from dbo.product_images pi
                        where pi.status = 1
                          and pi.image_id = (select top 1 image_id
                                             from dbo.product_images
                                             where product_variation_id = pi.product_variation_id
                                             order by update_date)) pi
                       on pi.product_variation_id = pvd.product_variation_id
    where ci.cart_id = @cart_id
    for json path, include_null_values;
end;
go

exec dbo.view_cart '17376f11b261aa802c01'

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.calculate_cart_total @token varchar(20),
                                          @promo_code_id varchar(6) = null,
                                          @total_price decimal(10, 2) output
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @cart_id varchar(12);
    select @cart_id = c.cart_id
    from dbo.carts c
    where c.user_id = @user_id;

    if @cart_id is null
        begin
            set @total_price = 0;
            return;
        end

    declare @discount_percentage decimal(5, 2) = 0;
    if @promo_code_id is not null
        begin
            select @discount_percentage = pc.discount
            from dbo.promo_codes pc
            where pc.promo_code_id = @promo_code_id
              and pc.status = 1
              and pc.start_date <= getutcdate()
              and pc.end_date >= getutcdate();
        end

    select @total_price = sum(
            ci.quantity *
            (IIF(pd.promo_code_id is not null and pd.promo_code_id = @promo_code_id,
                 ci.price * (1 - @discount_percentage / 100), ci.price))
                          )
    from dbo.cart_items ci
             left join dbo.product_discounts pd
                       on ci.product_id = pd.product_variation_id
    where ci.cart_id = @cart_id
      and ci.is_selected = 1;

    if @total_price is null
        set @total_price = 0;
end;
go

select *
from dbo.product_discounts

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.update_cart_item_quantity @token varchar(20),
                                               @cart_item_id varchar(12),
                                               @quantity int,
                                               @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);
    declare @cart_id varchar(12)=(select cart_id from dbo.cart_items where cart_item_id = @cart_item_id);

    if @user_id is null
        return;

    declare @cart_owner_id varchar(12) = (select user_id from dbo.carts where cart_id = @cart_id);

    if @cart_owner_id is null or @cart_owner_id != @user_id
        return;

    if not exists (select 1
                   from dbo.cart_items
                   where cart_item_id = @cart_item_id)
        return;

    if @quantity <= 0
        begin
            delete
            from dbo.cart_items
            where cart_item_id = @cart_item_id;

            set @sql_result = 1;
            return;
        end

    declare @variation_code varchar(6)=(select product_id from dbo.cart_items where cart_item_id = @cart_item_id);

    declare @available_quantity int;
    select @available_quantity = i.quantity
    from dbo.inventory i
    where i.product_variations_id = @variation_code;

    if @available_quantity < @quantity
        begin
            return;
        end

    update dbo.cart_items
    set quantity = @quantity
    where cart_item_id = @cart_item_id;

    set @sql_result = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.toggle_is_selected @token varchar(20),
                                        @cart_item_id varchar(12),
                                        @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    declare @cart_id varchar(12) = (select cart_id from dbo.cart_items where cart_item_id = @cart_item_id);

    if @cart_id is null
        return;

    declare @cart_owner_id varchar(12) = (select user_id from dbo.carts where cart_id = @cart_id);

    if @cart_owner_id is null or @cart_owner_id != @user_id
        return;

    if not exists (select 1 from dbo.cart_items where cart_item_id = @cart_item_id)
        return;

    declare @current_is_selected bit;
    select @current_is_selected = is_selected
    from dbo.cart_items
    where cart_item_id = @cart_item_id;

    update dbo.cart_items
    set is_selected = case when @current_is_selected = 1 then 0 else 1 end,
        update_date = getutcdate()
    where cart_item_id = @cart_item_id;

    set @sql_result = 1;
end;
go;

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.validate_promo_code @token varchar(20),
                                         @promo_code_id varchar(6),
                                         @is_valid bit output
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        begin
            set @is_valid = 0;
            return;
        end

    declare @cart_id varchar(12);
    select @cart_id = c.cart_id
    from dbo.carts c
    where c.user_id = @user_id;

    if @cart_id is null
        begin
            set @is_valid = 0;
            return;
        end

    declare @promo_code_exists bit = (select count(1)
                                      from dbo.promo_codes pc
                                      where pc.promo_code_id = @promo_code_id
                                        and pc.status = 1
                                        and pc.start_date <= getutcdate()
                                        and pc.end_date >= getutcdate());

    if @promo_code_exists = 0
        begin
            set @is_valid = 0;
            return;
        end

    declare @is_related_to_cart bit = (select count(1)
                                       from dbo.cart_items ci
                                                join dbo.product_discounts pd on ci.product_id = pd.product_variation_id
                                       where ci.cart_id = @cart_id
                                         and ci.is_selected = 1
                                         and pd.promo_code_id = @promo_code_id);

    if @is_related_to_cart > 0
        set @is_valid = 1;
    else
        set @is_valid = 0;
end;
go

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.checkout @token varchar(20),
                              @promo_code_id varchar(6) = null,
                              @address_id varchar(12),
                              @bank_card_id varchar(6),
                              @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

        if @user_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.user_addresses where user_id = @user_id and address_id = @address_id)
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.user_bank_cards where user_id = @user_id and bank_carts_id = @bank_card_id)
            begin
                rollback transaction;
                return;
            end

        declare @cart_id varchar(12);
        select @cart_id = c.cart_id
        from dbo.carts c
        where c.user_id = @user_id;

        if @cart_id is null
            begin
                rollback transaction;
                return;
            end

        declare @total_amount decimal(10, 2) = 0;

        if @promo_code_id is not null
            begin
                declare @is_used bit = (select is_used
                                        from dbo.user_promo_codes upc
                                        where upc.user_id = @user_id
                                          and upc.promo_code_id = @promo_code_id);
                if @is_used = 1
                    begin
                        rollback transaction;
                        return;
                    end
            end

        select @total_amount = sum(
                case
                    when pd.promo_code_id = @promo_code_id then ci.quantity * ci.price * (1 - pc.discount / 100)
                    else ci.quantity * ci.price
                    end
                               )
        from dbo.cart_items ci
                 left join dbo.product_discounts pd on ci.product_id = pd.product_variation_id
                 left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
        where ci.cart_id = @cart_id
          and ci.is_selected = 1
          and (pc.promo_code_id is null
            or (pc.start_date <= getutcdate() and pc.end_date >= getutcdate() and pc.status = 1));

        insert into dbo.orders (user_id, promo_code_id, total_amount)
        values (@user_id, @promo_code_id, @total_amount);

        declare @order_id varchar(12) = (select order_id from dbo.orders where id = scope_identity());

        insert into dbo.shipping_details(order_id, address_id) values (@order_id, @address_id);

        insert into dbo.order_item (order_id, product_id, quantity, price)
        select @order_id, ci.product_id, ci.quantity, ci.price
        from dbo.cart_items ci
        where ci.cart_id = @cart_id
          and ci.is_selected = 1;

        update dbo.inventory
        set dbo.inventory.quantity = dbo.inventory.quantity - ci.quantity
        from dbo.inventory
                 join dbo.cart_items ci on dbo.inventory.product_variations_id = ci.product_id
        where ci.cart_id = @cart_id
          and ci.is_selected = 1;

        if exists (select 1 from dbo.inventory where quantity < 0)
            begin
                rollback transaction;
                return;
            end

        delete from dbo.cart_items where cart_id = @cart_id and is_selected = 1;

        if @promo_code_id is not null
            begin
                insert into dbo.user_promo_codes (user_id, promo_code_id)
                values (@user_id, @promo_code_id);
            end

        insert into dbo.transactions (order_id, bank_card_id, total_amount, payment_status_id)
        values (@order_id, @bank_card_id, @total_amount, 2);

        commit transaction;
        set @sql_result = 1;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go
*/

create procedure dbo.checkout @token varchar(20),
                              @promo_code_id varchar(6) = null,
                              @address_id varchar(12),
                              @bank_card_id varchar(6),
                              @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

        if @user_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.user_addresses where user_id = @user_id and address_id = @address_id)
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.user_bank_cards where user_id = @user_id and bank_carts_id = @bank_card_id)
            begin
                rollback transaction;
                return;
            end

        declare @cart_id varchar(12);
        select @cart_id = c.cart_id
        from dbo.carts c
        where c.user_id = @user_id;

        if @cart_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.cart_items where cart_id = @cart_id and is_selected = 1)
            begin
                rollback transaction;
                return;
            end

        declare @total_amount decimal(10, 2) = 0;

        if @promo_code_id is not null
            begin
                declare @is_used bit = (select is_used
                                        from dbo.user_promo_codes upc
                                        where upc.user_id = @user_id
                                          and upc.promo_code_id = @promo_code_id);
                if @is_used = 1
                    begin
                        rollback transaction;
                        return;
                    end
            end

        select @total_amount = sum(
                case
                    when pd.promo_code_id = @promo_code_id then ci.quantity * ci.price * (1 - pc.discount / 100)
                    else ci.quantity * ci.price
                    end
                               )
        from dbo.cart_items ci
                 left join dbo.product_discounts pd on ci.product_id = pd.product_variation_id
                 left join dbo.promo_codes pc on pd.promo_code_id = pc.promo_code_id
        where ci.cart_id = @cart_id
          and ci.is_selected = 1
          and (pc.promo_code_id is null
            or (pc.start_date <= getutcdate() and pc.end_date >= getutcdate() and pc.status = 1));

        insert into dbo.orders (user_id, promo_code_id, total_amount)
        values (@user_id, @promo_code_id, @total_amount);

        declare @order_id varchar(12) = (select order_id from dbo.orders where id = scope_identity());

        -- Добавление деталей доставки
        insert into dbo.shipping_details(order_id, address_id) values (@order_id, @address_id);

        insert into dbo.order_item (order_id, product_id, quantity, price)
        select @order_id, ci.product_id, ci.quantity, ci.price
        from dbo.cart_items ci
        where ci.cart_id = @cart_id
          and ci.is_selected = 1;

        update dbo.inventory
        set dbo.inventory.quantity = dbo.inventory.quantity - ci.quantity
        from dbo.inventory
                 join dbo.cart_items ci on dbo.inventory.product_variations_id = ci.product_id
        where ci.cart_id = @cart_id
          and ci.is_selected = 1;

        if exists (select 1 from dbo.inventory where quantity < 0)
            begin
                rollback transaction;
                return;
            end

        delete from dbo.cart_items where cart_id = @cart_id and is_selected = 1;

        if @promo_code_id is not null
            begin
                insert into dbo.user_promo_codes (user_id, promo_code_id)
                values (@user_id, @promo_code_id);
            end

        insert into dbo.transactions (order_id, bank_card_id, total_amount, payment_status_id)
        values (@order_id, @bank_card_id, @total_amount, 2);

        commit transaction;
        set @sql_result = 1;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go;

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_view_user_orders @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        begin
            select null as result for json path, without_array_wrapper;
            return;
        end;

    if exists (select 1 from dbo.orders o where o.user_id = @user_id)
        begin
            select o.order_id,
                   ds.name  as order_status,
                   p.[name] as product_name,
                   mc.id    as main_category_id,
                   pv.variation_code,
                   pi.url   as first_image_url,
                   o.update_date
            from dbo.orders o
                     join dbo.order_item oi on o.order_id = oi.order_id
                     join dbo.product_variation_details pvd on oi.product_id = pvd.product_variation_id
                     join dbo.product_variations pv on pvd.product_variation_id = pv.variation_code
                     join dbo.products p on pv.product_id = p.product_id
                     join dbo.main_categories mc on p.main_category_id = mc.id
                     join dbo.product_images pi on pv.variation_code = pi.product_variation_id
                     join dbo.shipping_details sd on o.order_id = sd.order_id
                     join dbo.delivery_state ds on sd.shipping_status = ds.state_id
            where o.user_id = @user_id
              and pi.id = (select top 1 id from dbo.product_images where product_variation_id = pv.variation_code)
            group by o.order_id, ds.name, p.[name], mc.id, pv.variation_code, pi.url, o.update_date
            order by o.update_date desc
            for json path;
        end
    else
        begin
            select null as result for json path, without_array_wrapper;
        end
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_delete_account @token varchar(20),
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0
    declare @user_id varchar(12) = (select user_id from dbo.sessions where token = @token and status = 1);

    if @user_id is null
        return;

    update dbo.user_accounts
    set user_status_id = 3,
        update_date=getutcdate()
    where user_id = @user_id
      and user_status_id = 1;
    if @@rowcount = 1
        begin
            update dbo.sessions
            set status=0,
                update_date=getutcdate(),
                logout_date = getutcdate()
            where user_id = @user_id
            if @@rowcount >= 1
                begin
                    set @sql_result = 1
                end
        end
end;
go
