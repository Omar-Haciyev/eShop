use eCommerceDb
------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_add_main_category @token varchar(20),
                                     @main_category_name varchar(15),
                                     @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if exists(select 1 from dbo.main_categories where name = @main_category_name)
        return;

    insert into dbo.main_categories(name) values (@main_category_name);

    if @@rowcount = 1
        set @sql_result = 1
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_main_category @token varchar(20),
                                        @main_category_id int,
                                        @name varchar(15),
                                        @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.main_categories set name=@name, update_date=getutcdate() where id = @main_category_id and status = 1;

    if @@rowcount = 1
        set @sql_result = 1;
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_delete_main_category @token varchar(20),
                                             @main_category_id int,
                                             @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.main_categories set status = 0, update_date = getutcdate() where id = @main_category_id and status = 1;

    if @@rowcount = 1
        begin
            set @sql_result = 1;

            update dbo.main_category_sub_category_links
            set status      = 0,
                update_date = getutcdate()
            where main_category_id = @main_category_id
              and status = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_add_category @token varchar(20),
                                     @category_name varchar(25),
                                     @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if exists(select 1 from dbo.categories where name = @category_name)
        return;

    insert into dbo.categories (name) values (@category_name);

    if @@rowcount = 1
        set @sql_result = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_category @token varchar(20),
                                   @category_id int,
                                   @name varchar(15),
                                   @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.categories set name=@name, update_date=getutcdate() where id = @category_id and status = 1;

    if @@rowcount = 1
        set @sql_result = 1;
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_delete_category @token varchar(20),
                                   @category_id int,
                                   @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.categories set status=0, update_date=getutcdate() where id = @category_id and status = 1;

    if @@rowcount = 1
        begin
            set @sql_result = 1;

            update dbo.main_category_sub_category_links
            set status      = 0,
                update_date = getutcdate()
            where category_id = @category_id
              and status = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_add_sub_category @token varchar(20),
                                         @category_id int,
                                         @sub_category_name varchar(25),
                                         @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1 from dbo.categories where id = @category_id)
        return;

    if exists(select 1 from dbo.sub_categories where name = @sub_category_name)
        return;

    insert into dbo.sub_categories (category_id, name) values (@category_id, @sub_category_name);

    if @@rowcount = 1
        set @sql_result = 1;
end;
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_sub_category @token varchar(20),
                                       @sub_category_id int,
                                       @name varchar(15),
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.sub_categories set name=@name, update_date=getutcdate() where id = @sub_category_id and status = 1;

    if @@rowcount = 1
        set @sql_result = 1;
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_delete_sub_category @token varchar(20),
                                       @sub_category_id int,
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    update dbo.sub_categories set status=0, update_date=getutcdate() where id = @sub_category_id and status = 1;

    if @@rowcount = 1
        begin
            set @sql_result = 1;

            update dbo.main_category_sub_category_links
            set status      = 0,
                update_date = getutcdate()
            where sub_category_id = @sub_category_id
              and status = 1;
        end
end
go

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.sp_create_category_hierarchy @token varchar(20),
                                                  @main_category_id_list dbo.main_category_id_list readonly,
                                                  @sub_category_id int,
                                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    declare @category_id int = (select category_id
                                from dbo.sub_categories
                                where id = @sub_category_id);

    if @category_id is null
        return;

    insert into dbo.main_category_sub_category_links (main_category_id, category_id, sub_category_id)
    select m.main_category_id, @category_id, @sub_category_id
    from @main_category_id_list m
    where not exists (select 1
                      from dbo.main_category_sub_category_links
                      where main_category_id = m.main_category_id
                        and category_id = @category_id
                        and sub_category_id = @sub_category_id);

    if @@rowcount > 0
        set @sql_result = 1;
end;
go

declare @main_category_ids dbo.main_category_id_list;
insert into @main_category_ids
values (11),
       (12);

declare @result bit;
exec dbo.sp_create_category_hierarchy @token='a4430067b494ef181a7d', @main_category_id_list = @main_category_ids,
     @sub_category_id = 19, @sql_result = @result output;
select @result;

*/


create procedure dbo.sp_create_category_hierarchy @token varchar(20),
                                                  @main_category_id_list dbo.main_category_id_list readonly,
                                                  @sub_category_id_list dbo.sub_category_id_list readonly,
                                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if exists (select 1
               from @main_category_id_list m
               where not exists (select 1 from dbo.main_categories c where c.id = m.main_category_id))
        return;

    if exists (select 1
               from @sub_category_id_list s
               where not exists (select 1 from dbo.sub_categories sc where sc.id = s.sub_category_id))
        return;


    insert into dbo.main_category_sub_category_links (main_category_id, category_id, sub_category_id)
    select m.main_category_id,
           s.category_id,
           s.sub_category_id
    from @main_category_id_list m
             cross join (select sc.id as sub_category_id,
                                sc.category_id
                         from dbo.sub_categories sc
                                  inner join @sub_category_id_list l
                                             on sc.id = l.sub_category_id
                         where sc.status = 1) s
    where not exists (select 1
                      from dbo.main_category_sub_category_links
                      where main_category_id = m.main_category_id
                        and category_id = s.category_id
                        and sub_category_id = s.sub_category_id);

    if @@rowcount > 0
        set @sql_result = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_update_hierarchy @token varchar(20),
                                         @hierarchy_id int,
                                         @main_category_id int,
                                         @category_id int,
                                         @sub_category_id int,
                                         @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1
                   from dbo.main_category_sub_category_links
                   where id = @hierarchy_id)
        return;

    if not exists (select 1
                   from dbo.sub_categories
                   where id = @sub_category_id
                     and category_id = @category_id)
        return;

    update dbo.main_category_sub_category_links
    set update_date      = getutcdate(),
        main_category_id = @main_category_id,
        category_id      = @category_id,
        sub_category_id  = @sub_category_id
    where id = @hierarchy_id;

    if @@rowcount > 0
        set @sql_result = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_delete_hierarchy @token varchar(20),
                                         @hierarchy_id int,
                                         @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1
                   from dbo.main_category_sub_category_links
                   where id = @hierarchy_id)
        return;

    update dbo.main_category_sub_category_links
    set status=0,
        update_date=getutcdate()
    where id = @hierarchy_id

    if @@rowcount = 1
        set @sql_result = 1;
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_all_hierarchies @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1
                   from dbo.main_category_sub_category_links)
        begin
            select null as hierarchies for json path, root('hierarchies');
            return;
        end;


    select l.id,
           mc.name as main_category_name,
           c.name  as category_name,
           sc.name as sub_category_name,
           l.status
    from dbo.main_category_sub_category_links l
             inner join dbo.main_categories mc on l.main_category_id = mc.id
             inner join dbo.categories c on l.category_id = c.id
             inner join dbo.sub_categories sc on l.sub_category_id = sc.id
    for json path, root('hierarchies');
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_all_category_hierarchies_2 @token varchar(20)
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    select mc.id           as main_category_id,
           mc.name         as main_category_name,
           (select c.id            as category_id,
                   c.name          as category_name,
                   (select l.id    as hierarchy_id,
                           sc.id   as sub_category_id,
                           sc.name as sub_category_name,
                           l.status
                    from dbo.main_category_sub_category_links l
                             inner join dbo.sub_categories sc on l.sub_category_id = sc.id
                    where l.main_category_id = mc.id
                      and l.category_id = c.id
                    for json path) as sub_categories
            from dbo.categories c
            where exists (select 1
                          from dbo.main_category_sub_category_links l
                          where l.category_id = c.id
                            and l.main_category_id = mc.id)
            for json path) as categories
    from dbo.main_categories mc
    for json path, root('hierarchies');
end;
go

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.sp_add_product @token varchar(20),
                                    @main_category_id int,
                                    @sub_category_id int,
                                    @product_name varchar(50),
                                    @gender_id int,
                                    @make varchar(25),
                                    @fabric varchar(25),
                                    @description varchar(200) = null,
                                    @color_code varchar(7),
                                    @price decimal(10, 2),
                                    @image_urls dbo.image_url_list readonly,
                                    @quantity smallint,
                                    @sizes dbo.size_list readonly,
                                    @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        declare @category_id int = (select category_id from dbo.sub_categories where id = @sub_category_id);

        if not exists (select 1
                       from dbo.main_category_sub_category_links
                       where main_category_id = @main_category_id
                         and category_id = @category_id
                         and sub_category_id = @sub_category_id)
            begin
                rollback transaction;
                return;
            end

        if exists (select 1 from dbo.products where name = @product_name and sub_category_id = @sub_category_id)
            begin
                rollback transaction;
                return;
            end

        declare @image_count int = (select count(*) from @image_urls);
        if @image_count < 1 or @image_count > 5
            begin
                rollback transaction;
                return;
            end

        insert into dbo.products (main_category_id, sub_category_id, name, clothing_gender_id)
        values (@main_category_id, @sub_category_id, @product_name, @gender_id);

        declare @product_id varchar(12) = (select product_id from dbo.products where id = scope_identity());

        if @product_id is null
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_variations (product_id) values (@product_id);
        declare @variation_code varchar(6) = (select variation_code
                                              from dbo.product_variations
                                              where id = scope_identity());

        if @variation_code is null
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_variation_details (product_variation_id, make, fabric, description, color_id, price)
        values (@variation_code, @make, @fabric, @description, @color_code, @price);

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_price_history(product_id, price) values (@variation_code, @price);

        insert into dbo.product_images (product_variation_id, url)
        select @variation_code, image_url
        from @image_urls;

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.inventory where product_variations_id = @variation_code)
            begin
                insert into dbo.inventory (product_variations_id, quantity)
                values (@variation_code, @quantity);
            end

        insert into dbo.sizes (size)
        select distinct size
        from @sizes s
        where not exists (select 1 from dbo.sizes sz where sz.size = s.size);

        insert into dbo.product_variation_sizes (product_variation_id, size_id)
        select @variation_code, sz.id
        from @sizes s
                 join dbo.sizes sz on sz.size = s.size;

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback transaction;
            end
        set @sql_result = 0;
    end catch
end
go

declare @image_urls dbo.image_url_list;
insert into @image_urls (image_url)
values ('http://example.com/omariot11.jpg'),
       ('http://example.com/omariot12.jpg'),
       ('http://example.com/omariot13.jpg');

declare @sizes dbo.size_list;
insert into @sizes (size)
values ('35'),
       ('36'),
       ('37'),
       ('38'),
       ('39'),
       ('40'),
       ('41'),
       ('42'),
       ('43'),
       ('44'),
       ('45'),
       ('46'),
       ('47');

declare @result bit;
exec dbo.sp_add_product
     @token = 'a4430067b494ef181a7d',
     @main_category_id = 11,
     @sub_category_id = 18,
     @product_name = 'DunkOmariot_2',
     @gender_id =1,
     @make = 'Make_Omar_2',
     @fabric = 'Fabric_Omar_2',
     @description = 'Description_Omar_2',
     @color_code = '#6c6377',
     @price = 100.00,
     @image_urls = @image_urls,
     @quantity = 10,
     @sizes = @sizes,
     @sql_result = @result output;

select @result as Result;

select *
from dbo.products
*/

create procedure dbo.sp_add_product @token varchar(20),
                                    @main_category_id int,
                                    @sub_category_id int,
                                    @product_name varchar(50),
                                    @gender_id int,
                                    @make varchar(25),
                                    @fabric varchar(25),
                                    @description varchar(200) = null,
                                    @color_code varchar(7),
                                    @price decimal(10, 2),
                                    @quantity smallint,
                                    @sizes dbo.size_list readonly,
                                    @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        declare @category_id int = (select category_id from dbo.sub_categories where id = @sub_category_id);

        if not exists (select 1
                       from dbo.main_category_sub_category_links
                       where main_category_id = @main_category_id
                         and category_id = @category_id
                         and sub_category_id = @sub_category_id)
            begin
                rollback transaction;
                return;
            end

        if exists (select 1 from dbo.products where name = @product_name and sub_category_id = @sub_category_id)
            begin
                rollback transaction;
                return;
            end

        insert into dbo.products (main_category_id, sub_category_id, name, clothing_gender_id)
        values (@main_category_id, @sub_category_id, @product_name, @gender_id);

        declare @product_id varchar(12) = (select product_id from dbo.products where id = scope_identity());

        if @product_id is null
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_variations (product_id) values (@product_id);
        declare @variation_code varchar(6) = (select variation_code
                                              from dbo.product_variations
                                              where id = scope_identity());

        if @variation_code is null
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_variation_details (product_variation_id, make, fabric, description, color_id, price)
        values (@variation_code, @make, @fabric, @description, @color_code, @price);

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_price_history(product_id, price) values (@variation_code, @price);

        if not exists (select 1 from dbo.inventory where product_variations_id = @variation_code)
            begin
                insert into dbo.inventory (product_variations_id, quantity)
                values (@variation_code, @quantity);
            end

        insert into dbo.sizes (size)
        select distinct size
        from @sizes s
        where not exists (select 1 from dbo.sizes sz where sz.size = s.size);

        insert into dbo.product_variation_sizes (product_variation_id, size_id)
        select @variation_code, sz.id
        from @sizes s
                 join dbo.sizes sz on sz.size = s.size;

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go


/*

declare @sizes dbo.size_list;
insert into @sizes (size)
values ('40'),
       ('41'),
       ('42');

declare @result bit;
exec dbo.sp_add_product
     @token = '604547425fb7b0ce3fa0',
     @main_category_id = 11,
     @sub_category_id = 13,
     @product_name = 'Omar krosi',
     @gender_id =1,
     @make = 'Omar Make',
     @fabric = 'Omar Fabric',
     @description = 'Omar Description',
     @color_code = '#ff0000',
     @price = 1700,
     @quantity = 7,
     @sizes = @sizes,
     @sql_result = @result output;

select @result as Result;

*/

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_add_product_images @token varchar(20),
                                           @product_variation_id varchar(6),
                                           @image_urls dbo.image_url_list readonly,
                                           @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.product_variations where variation_code = @product_variation_id)
            begin
                rollback transaction;
                return;
            end

        declare @image_count int = (select count(*) from @image_urls);
        if @image_count < 1 or @image_count > 5
            begin
                rollback transaction;
                return;
            end

        insert into dbo.product_images (product_variation_id, url)
        select @product_variation_id, image_url
        from @image_urls;

        if @@rowcount = 0
            begin
                rollback transaction;
                return;
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_product @token varchar(20),
                                  @product_id varchar(12),
                                  @main_category_id int,
                                  @sub_category_id int,
                                  @product_name varchar(50),
                                  @gender_id int,
                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.products where product_id = @product_id)
            begin
                rollback transaction;
                return;
            end

        update dbo.products
        set main_category_id   = coalesce(@main_category_id, main_category_id),
            sub_category_id    = coalesce(@sub_category_id, sub_category_id),
            name               = coalesce(@product_name, name),
            clothing_gender_id = coalesce(@gender_id, clothing_gender_id),
            update_date        = getutcdate()
        where product_id = @product_id;

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_delete_product_images @token varchar(20),
                                              @product_variation_id varchar(6),
                                              @image_to_delete_ids dbo.image_id_list readonly,
                                              @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.product_variations where variation_code = @product_variation_id)
            begin
                rollback transaction;
                return;
            end

        if exists (select 1 from @image_to_delete_ids)
            begin
                delete
                from dbo.product_images
                where image_id in (select image_id from @image_to_delete_ids)
                  and product_variation_id = @product_variation_id;

                if @@rowcount = 0
                    begin
                        rollback transaction;
                        return;
                    end
            end

        declare @remaining_images int = (select count(*)
                                         from dbo.product_images
                                         where product_variation_id = @product_variation_id);

        if @remaining_images < 1
            begin
                rollback transaction;
                return;
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go

------------------------------------------------------------------------------------------------------------------------

create proc sp_get_image_urls @product_variation_id NVARCHAR(50),
                                   @image_ids dbo.image_id_list readonly
as
begin
    select i.url
    from product_images i
             inner join
         @image_ids ids on i.image_id = ids.image_id
    where i.product_variation_id = @product_variation_id;
end
go;

/*
create procedure dbo.sp_get_image_urls @token varchar(20),
                                   @product_variation_id varchar(6),
                                   @image_to_get_ids dbo.image_id_list readonly,
                                   @status_code int output
as
begin
set nocount on;

begin try
    set @status_code = 500;

    declare @user_id varchar(12) = (select user_id
                                    from sessions
                                    where token = @token
                                      and status = 1);

    declare @admin_id varchar(12) = (select user_id
                                     from dbo.user_accounts_admins
                                     where user_id = @user_id);

    if @admin_id is null
        begin
            set @status_code = 400;
            select 'Access denied. User is not an administrator.' as message
            for json path, without_array_wrapper;
            return;
        end

    if not exists (select 1
                   from dbo.product_variations
                   where variation_code = @product_variation_id)
        begin
            set @status_code = 400;
            select 'Product variation does not exist.' as message
            for json path, without_array_wrapper;
            return;
        end

    if not exists (select 1 from @image_to_get_ids)
        begin
            set @status_code = 400;
            select 'No image IDs provided for retrieval.' as message
            for json path, without_array_wrapper;
            return;
        end

    select image_id,
           url
    from dbo.product_images
    where image_id in (select image_id from @image_to_get_ids)
      and product_variation_id = @product_variation_id
    for json auto, without_array_wrapper;

    set @status_code = 200;
end try
begin catch
    -- Обработка ошибок
    set @status_code = 500;
    select error_message() as message
    for json path, without_array_wrapper;
end catch
end
go
*/

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_update_inventory_quantity @token varchar(20),
                                                  @product_variation_id varchar(6),
                                                  @new_quantity int,
                                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1 from dbo.inventory where product_variations_id = @product_variation_id)
        return;

    update dbo.inventory
    set quantity = @new_quantity
    where product_variations_id = @product_variation_id;

    if @@rowcount = 1
        set @sql_result = 1;
end
go

------------------------------------------------------------------------------------------------------------------------

/*
create proc dbo.sp_add_product_variations @token varchar(20),
                                          @product_id varchar(12),
                                          @make varchar(25),
                                          @fabric varchar(25),
                                          @description varchar(200) = null,
                                          @color_id varchar(7),
                                          @price decimal(10, 2),
                                          @image_urls dbo.image_url_list readonly,
                                          @quantity smallint,
                                          @sizes dbo.size_list readonly,
                                          @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            return;

        if not exists (select 1 from dbo.products where product_id = @product_id and status = 1)
            return;

        insert into dbo.product_variations (product_id)
        values (@product_id);

        declare @variation_code varchar(6) = (select variation_code
                                              from dbo.product_variations
                                              where id = scope_identity());

        insert into dbo.product_variation_details (product_variation_id, make, fabric, description, color_id, price)
        values (@variation_code, @make, @fabric, @description, @color_id, @price);

        insert into dbo.product_price_history (product_id, price)
        values (@variation_code, @price);

        insert into dbo.product_images (product_variation_id, url)
        select @variation_code, image_url
        from @image_urls;

        insert into dbo.inventory (product_variations_id, quantity)
        values (@variation_code, @quantity);

        insert into dbo.product_variation_sizes (product_variation_id, size_id)
        select @variation_code, s.id
        from @sizes as sz
                 join dbo.sizes as s on s.size = sz.size;

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback transaction;
            end
        set @sql_result = 0;
    end catch
end
go

declare @image_urls_table dbo.image_url_list;
insert into @image_urls_table (image_url)
values ('https://example.com/variation_1.jpg'),
       ('https://example.com/variation_2.jpg');

declare @sizes_table dbo.size_list;
insert into @sizes_table (size)
values ('42'),
       ('43'),
       ('44');

select *
from dbo.sessions
declare @result bit;

exec dbo.sp_add_product_variations
     @token = 'a4430067b494ef181a7d',
     @product_id = '5591f8b05a01',
     @make = 'Omar_Variation_2',
     @fabric = 'Omar_Fabric_Variation_2',
     @description = 'High-quality leather shoes',
     @color_id = '#6c6377',
     @price = 99.99,
     @image_urls = @image_urls_table,
     @quantity = 50,
     @sizes = @sizes_table,
     @sql_result = @result output;

select @result;
*/

create proc dbo.sp_add_product_variations @token varchar(20),
                                         @product_id varchar(12),
                                         @make varchar(25),
                                         @fabric varchar(25),
                                         @description varchar(200) = null,
                                         @color_id varchar(7),
                                         @price decimal(10, 2),
                                         @quantity smallint,
                                         @sizes dbo.size_list readonly,
                                         @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            return;

        if not exists (select 1 from dbo.products where product_id = @product_id and status = 1)
            return;

        insert into dbo.product_variations (product_id)
        values (@product_id);

        declare @variation_code varchar(6) = (select variation_code
                                              from dbo.product_variations
                                              where id = scope_identity());

        insert into dbo.product_variation_details (product_variation_id, make, fabric, description, color_id, price)
        values (@variation_code, @make, @fabric, @description, @color_id, @price);

        insert into dbo.product_price_history (product_id, price)
        values (@variation_code, @price);

        insert into dbo.inventory (product_variations_id, quantity)
        values (@variation_code, @quantity);

        insert into dbo.product_variation_sizes (product_variation_id, size_id)
        select @variation_code, s.id
        from @sizes as sz
                 join dbo.sizes as s on s.size = sz.size;

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go


------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_product_variations @token varchar(20),
                                             @variation_code varchar(6),
                                             @make varchar(25),
                                             @fabric varchar(25),
                                             @description varchar(200),
                                             @color_id varchar(7),
                                             @price decimal(10, 2),
                                             @image_urls dbo.image_url_list readonly,
                                             @quantity smallint,
                                             @sizes dbo.size_list readonly,
                                             @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1 from dbo.product_variations where variation_code = @variation_code)
            begin
                rollback transaction;
                return;
            end

        update dbo.product_variation_details
        set make        = coalesce(@make, make),
            fabric      = coalesce(@fabric, fabric),
            description = coalesce(@description, description),
            color_id    = coalesce(@color_id, color_id),
            price       = coalesce(@price, price),
            update_date = getutcdate()
        where product_variation_id = @variation_code;

        if @price is not null
            begin
                insert into dbo.product_price_history (product_id, price)
                values (@variation_code, @price);
            end

        if exists (select 1 from @image_urls)
            begin
                delete from dbo.product_images where product_variation_id = @variation_code;
                insert into dbo.product_images (product_variation_id, url)
                select @variation_code, image_url
                from @image_urls;
            end

        if @quantity is not null
            begin
                update dbo.inventory
                set quantity = @quantity
                where product_variations_id = @variation_code;
            end

        if exists (select 1 from @sizes)
            begin
                delete from dbo.product_variation_sizes where product_variation_id = @variation_code;

                insert into dbo.sizes (size)
                select distinct size
                from @sizes s
                where not exists (select 1 from dbo.sizes sz where sz.size = s.size);

                insert into dbo.product_variation_sizes (product_variation_id, size_id)
                select @variation_code, sz.id
                from @sizes s
                         join dbo.sizes sz on sz.size = s.size;
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_deactivate_product @token varchar(20),
                                      @product_id varchar(12),
                                      @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if exists(select 1 from dbo.products where product_id = @product_id and status = 1)
        begin
            update dbo.products set status=0, update_date=getutcdate() where product_id = @product_id;

            if @@rowcount = 1
                begin
                    set @sql_result = 1

                    update dbo.product_variations
                    set status=0,
                        update_date=getutcdate()
                    where product_id = @product_id
                      and status = 1
                end
        end
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_update_order_status @token varchar(20),
                                       @order_id varchar(12),
                                       @status_id int,
                                       @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);

    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    if not exists (select 1 from dbo.orders where order_id = @order_id)
        return;

    update dbo.admin_actions
    set status_id   = @status_id,
        update_date = getutcdate()
    where order_id = @order_id
      and user_id = @admin_id;

    if @@rowcount = 1
        begin
            update dbo.shipping_details
            set shipping_status = @status_id,
                update_date     = getutcdate()
            where order_id = @order_id;

            if @@rowcount = 1
                set @sql_result = 1;
        end
end;
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_select_all_users @token varchar(20),
                                    @page_number int = 1,
                                    @page_size int = 15
as
begin
    set nocount on;

    declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
    declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

    if @admin_id is null
        return;

    declare @offset int = (@page_number - 1) * @page_size;

    select u.id,
           u.email,
           s.status_name as status,
           r.name        as role
    from dbo.user_accounts u
             join dbo.user_statuses s on u.user_status_id = s.status_id
             join dbo.user_roles ur on u.user_id = ur.user_id
             join dbo.roles r on ur.role_id = r.role_id
    where u.user_status_id in (0, 1, 3)
    order by u.id
    offset @offset rows fetch next @page_size rows only
    for json path;
end;
go;

exec dbo.sp_select_all_users 'a4430067b494ef181a7d'


------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_add_promo_code_with_links @token varchar(20),
                                                  @description varchar(50),
                                                  @discount decimal(5, 2),
                                                  @start_date datetime,
                                                  @end_date datetime,
                                                  @main_category_id int = null,
                                                  @category_id int = null,
                                                  @sub_category_id int = null,
                                                  @product_variation_id varchar(6) = null,
                                                  @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if @discount < 0 or @discount > 100
            begin
                rollback transaction;
                return;
            end

        if @start_date >= @end_date
            begin
                rollback transaction;
                return;
            end

        insert into dbo.promo_codes (description, discount, start_date, end_date)
        values (@description, @discount, @start_date, @end_date);

        declare @promo_code_id varchar(6)=(select promo_code_id from dbo.promo_codes where id = scope_identity());

        if @main_category_id is not null
            begin
                insert into dbo.main_category_discounts (main_category_id, promo_code_id)
                values (@main_category_id, @promo_code_id);
            end

        if @category_id is not null
            begin
                insert into dbo.category_discounts (category_id, promo_code_id)
                values (@category_id, @promo_code_id);
            end

        if @sub_category_id is not null
            begin
                insert into dbo.sub_category_discounts (sub_category_id, promo_code_id)
                values (@sub_category_id, @promo_code_id);
            end

        if @product_variation_id is not null
            begin
                insert into dbo.product_discounts (product_variation_id, promo_code_id)
                values (@product_variation_id, @promo_code_id);
            end

        set @sql_result = 1;
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end
go

declare @sql_res bit;
exec dbo.sp_add_promo_code_with_links null, 20, '11/4/24', '11/10/24', 11, null, null, 'a063b4', @sql_res output;
select @sql_res;

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_update_promo_code @token varchar(20),
                                          @promo_code_id varchar(6),
                                          @description varchar(50) = null,
                                          @discount decimal(5, 2) = null,
                                          @start_date datetime = null,
                                          @end_date datetime = null,
                                          @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1
                       from dbo.promo_codes
                       where promo_code_id = @promo_code_id)
            begin
                rollback transaction;
                return;
            end

        update dbo.promo_codes
        set description = @description,
            discount    = IIF(@discount is not null and @discount between 0 and 100, @discount, discount),
            start_date  = coalesce(@start_date, start_date),
            end_date    = coalesce(@end_date, end_date),
            update_date = getutcdate()
        where promo_code_id = @promo_code_id;

        if @@rowcount > 0
            set @sql_result = 1;

        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_delete_promo_code @token varchar(20),
                                          @promo_code_id varchar(6),
                                          @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1
                       from dbo.promo_codes
                       where promo_code_id = @promo_code_id
                         and status = 1)
            begin
                rollback transaction;
                return;
            end

        update dbo.promo_codes
        set status=0,
            update_date=getutcdate()
        where promo_code_id = @promo_code_id;

        if @@rowcount = 1
            begin
                set @sql_result = 1;
                update dbo.main_category_discounts
                set status=0,
                    update_date=getutcdate()
                where promo_code_id = @promo_code_id;

                update dbo.category_discounts
                set status=0,
                    update_date=getutcdate()
                where promo_code_id = @promo_code_id;

                update dbo.sub_category_discounts
                set status=0,
                    update_date=getutcdate()
                where promo_code_id = @promo_code_id;

                update dbo.product_discounts
                set status=0,
                    update_date=getutcdate()
                where promo_code_id = @promo_code_id;
            end
        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_link_promo_code @token varchar(20),
                                        @promo_code_id varchar(6),
                                        @main_category_id int = null,
                                        @category_id int = null,
                                        @sub_category_id int = null,
                                        @product_variation_id varchar(6) = null,
                                        @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;
    declare @insert_count int = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12) = (select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback transaction;
                return;
            end

        if not exists (select 1
                       from dbo.promo_codes
                       where promo_code_id = @promo_code_id
                         and status = 1
                         and getutcdate() between start_date and end_date)
            begin
                rollback transaction;
                return;
            end

        if @main_category_id is not null and exists (select 1 from dbo.main_categories where id = @main_category_id)
            begin
                insert into dbo.main_category_discounts (main_category_id, promo_code_id)
                values (@main_category_id, @promo_code_id);
                set @insert_count += 1;
            end

        if @category_id is not null and exists (select 1 from dbo.categories where id = @category_id)
            begin
                insert into dbo.category_discounts (category_id, promo_code_id)
                values (@category_id, @promo_code_id);
                set @insert_count += 1;
            end

        if @sub_category_id is not null and exists (select 1 from dbo.sub_categories where id = @sub_category_id)
            begin
                insert into dbo.sub_category_discounts (sub_category_id, promo_code_id)
                values (@sub_category_id, @promo_code_id);
                set @insert_count += 1;
            end

        if @product_variation_id is not null and
           exists (select 1 from dbo.product_variations where variation_code = @product_variation_id)
            begin
                insert into dbo.product_discounts (product_variation_id, promo_code_id)
                values (@product_variation_id, @promo_code_id);
                set @insert_count += 1;
            end

        if @insert_count > 0
            set @sql_result = 1;

        commit transaction;
    end try
    begin catch
        if @@trancount > 0
            rollback transaction;
        set @sql_result = 0;
    end catch
end;
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_deactivate_account @token varchar(20),
                                           @deleted_user_id varchar(12),
                                           @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin tran;
        declare @user_id varchar(12) = (select user_id from sessions where token = @token and status = 1);
        declare @admin_id varchar(12)=(select user_id from dbo.user_accounts_admins where user_id = @user_id);

        if @admin_id is null
            begin
                rollback tran;
                return;
            end

        update dbo.user_accounts
        set user_status_id = 0,
            update_date    = getutcdate()
        where user_id = @deleted_user_id
          and user_status_id = 1;

        if @@rowcount = 1
            begin
                update dbo.sessions set status = 3, update_date=getutcdate() where user_id = @deleted_user_id;
                if @@rowcount >= 0
                    begin
                        set @sql_result = 1;
                        commit tran;
                        return;
                    end
            end
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback tran;
            end
    end catch;
end
go

------------------------------------------------------------------------------------------------------------------------


