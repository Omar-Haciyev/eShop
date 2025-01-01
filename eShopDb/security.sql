use eCommerceDb
------------------------------------------------------------------------------------------------------------------------

create function dbo.fn_select_null_result()
    returns nvarchar(100)
as
begin
    return (select null as token,
                   null as user_id,
                   null as role,
                   null as expired_date
            for json path,without_array_wrapper ,include_null_values)
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_generate_token @platform_key varchar(12),
                                       @status_code int output,
                                       @session_id int output
as
begin
    set nocount on;

    if not exists (select 1 from dbo.platforms where platform_key = @platform_key and status = 1)
        begin
            set @status_code = 400;
            return;
        end

    insert into dbo.sessions (platform_id, expired_date)
    values (@platform_key, dateadd(hour, 3, getutcdate()));

    set @session_id = scope_identity();

    set @status_code = 200;
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_get_session_json @session_id int
as
begin
    set nocount on;

    select token,
           'guest' AS role,
           expired_date
    from dbo.sessions
    where id = @session_id
    for json path, without_array_wrapper;
end
go

------------------------------------------------------------------------------------------------------------------------

-- alter procedure dbo.sp_generate_token @platform_key varchar(12),
--                                       @status_code int output
-- as
-- begin
--     set nocount on;
--
--     if not exists (select 1 from dbo.platforms where platform_key = @platform_key and status = 1)
--         begin
--             set @status_code = 400;
--             return;
--         end
--
--     insert into dbo.sessions (platform_id, expired_date)
--     values (@platform_key, dateadd(hour, 3, getutcdate()));
--
--     set @status_code = 200;
--
--     select token,
--            'guest' AS role,
--            expired_date
--     from dbo.sessions
--     where id = scope_identity()
--     for json path ,without_array_wrapper;
-- end
-- go

------------------------------------------------------------------------------------------------------------------------

alter procedure dbo.sp_validate_token_and_return_info @token varchar(20)
as
begin
    set nocount on;

    declare @status_id int, @expired_date datetime, @user_id varchar(12), @role varchar(15);

    select @status_id = s.status,
           @expired_date = s.expired_date,
           @user_id = u.user_id,
           @role = IIF(r.[name] is null, 'Guest', r.[name]) -- Я ИЗМЕНИЛ guest на Guest
    from dbo.sessions s
             left join dbo.user_accounts u on s.user_id = u.user_id
             left join dbo.user_roles ur on u.user_id = ur.user_id
             left join dbo.roles r on ur.role_id = r.role_id
    where s.token = @token;

    if @status_id is null or @status_id = 0 or @status_id = 3
        begin
            select dbo.fn_select_null_result();
            return;
        end

    if getutcdate() > @expired_date
        begin
            update dbo.sessions
            set status      = 0,
                update_date = getutcdate()
            where token = @token;

            select dbo.fn_select_null_result();
            return;
        end;

    select @token         as token,
           @user_id       as user_id,
           @role          as role,
           @expired_date  as expired_date,
           ss.status_name as status
    from dbo.session_statuses ss
    where ss.status_id = @status_id
    for json path, without_array_wrapper;
end
go

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_check_user_exists @token varchar(20),
                                          @email varchar(20),
                                          @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    if exists(select 1 from dbo.user_accounts where email = @email and user_status_id = 1)
        set @sql_result = 1;
end
go

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.sp_sign_up @token varchar(20),
                                @email varchar(100),
                                @password varchar(100),
                                @otp_code varchar(6),
                                @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12),@user_status_id int, @deleted_date datetime,@last_conf_code_token varchar(20),@last_resend_date datetime;

    select top 1 @user_id = user_id,
                 @user_status_id = user_status_id,
                 @deleted_date = deleted_date
    from dbo.user_accounts
    where email = @email
    order by id desc;

    select top 1 @last_resend_date = last_resend_time,
                 @last_conf_code_token = token
    from dbo.confirmation_codes
    where user_id = @user_id
    order by id desc;

    if @user_status_id = 2
        begin
            if @last_conf_code_token = @token
                begin
                    update dbo.confirmation_codes
                    set last_resend_time = getutcdate(),
                        code             = @otp_code,
                        update_date=getutcdate(),
                        expired_date     = dateadd(minute, 5, getutcdate())
                    where token = @token;

                    select 'OTP has been sent to your email.' as msg
                    for json path , without_array_wrapper;
                    set @sql_result = 1;
                    return;
                end
        end

    declare @last_token varchar(20);
    select top 1 @last_token = token
    from dbo.sessions
    where temp_user_id = @user_id
    order by id desc;

    if @user_status_id = 3 and datediff(day, @deleted_date, getutcdate()) <= 15
        begin
            if @last_token = @token
                begin
                    update dbo.sessions
                    set update_date=getutcdate(),
                        temp_password_hash=@password
                    where token = @token;

                    update dbo.confirmation_codes
                    set code=null,
                        choice_id=null,
                        update_date=getutcdate(),
                        expired_date=dateadd(minute, 5, getutcdate()),
                        last_resend_time=getutcdate()
                    where token = @token;

                    select 'Choose to restore your account or create a new one.' as msg
                    for json path ,without_array_wrapper;
                    set @sql_result = 1;
                    return;
                end
        end

    if @last_resend_date is not null and datediff(minute, @last_resend_date, getutcdate()) < 10
        begin
            select 'The process with this account is already in progress. Please try again later.' as error_msg
            for json path ,without_array_wrapper;
            return;
        end

    declare @temp_user_id varchar(12)=(select temp_user_id from dbo.sessions where token = @token);

    if @temp_user_id is not null
        begin
            delete from dbo.confirmation_codes where token = @token;

            update dbo.sessions set temp_user_id=null where token = @token;

            if exists (select 1 from dbo.user_accounts where user_id = @temp_user_id and user_status_id = 2)
                begin
                    delete from dbo.user_roles where user_id = @temp_user_id;
                    delete from dbo.user_accounts_clients where user_id = @temp_user_id;
                    delete from dbo.user_accounts where user_id = @temp_user_id;
                end
        end

    begin try
        begin tran;
        if @user_status_id = 0
            begin
                select 'This account is blocked.' AS error_msg
                for json path , without_array_wrapper;
                rollback tran;
                return;
            end

        if @user_status_id = 1
            begin
                select 'A user with this email already exists.' as error_msg
                for json path ,without_array_wrapper;
                rollback tran;
                return;
            end

        if @user_status_id = 2 and datediff(minute, @last_resend_date, getutcdate()) >= 10
            begin
                --delete from dbo.confirmation_codes where user_id = @user_id;
                delete from dbo.confirmation_codes where token = @last_token;

                update dbo.sessions
                set temp_user_id=null,
                    update_date=getutcdate()
                where token = @last_token;

                delete from user_roles where user_id = @user_id;
                delete from dbo.user_accounts_clients where user_id = @user_id;
                delete from dbo.user_accounts where user_id = @user_id;
                set @user_id = null;
            end

        if @user_status_id = 3 and datediff(day, @deleted_date, getutcdate()) <= 15
            begin
                --delete from dbo.confirmation_codes where user_id = @user_id;
                delete from dbo.confirmation_codes where token = @last_token;

                update dbo.sessions
                set temp_user_id=null,
                    update_date=getutcdate(),
                    temp_password_hash=null
                where token = @last_token;

                update dbo.sessions
                set temp_user_id=@user_id,
                    update_date=getutcdate(),
                    temp_password_hash=@password
                where token = @token;

                insert into dbo.confirmation_codes(user_id, token, code, choice_id, expired_date, last_resend_time)
                values (@user_id, @token, null, null, dateadd(minute, 5, getutcdate()), getutcdate());

                select 'Choose to restore your account or create a new one.' as msg
                for json path ,without_array_wrapper;
                set @sql_result = 1;
                commit tran;
                return;
            end

        delete from dbo.confirmation_codes where user_id = @user_id;

        if @user_id is null or @user_status_id = 3
            begin
                insert into dbo.user_accounts (email, password_hash)
                values (@email, @password);

                if @@rowcount = 1
                    begin
                        set @user_id = (select user_id from dbo.user_accounts where id = scope_identity());
                        insert into dbo.user_accounts_clients(user_id) values (@user_id);

                        if @@rowcount = 1
                            begin
                                insert into dbo.user_roles(user_id, role_id) values (@user_id, 0);

                                if @@rowcount = 1
                                    begin
                                        update dbo.sessions
                                        set temp_user_id=@user_id,
                                            update_date = getutcdate()
                                        where token = @token;

                                        if @@rowcount = 1
                                            begin
                                                insert into dbo.confirmation_codes(user_id, token, code,
                                                                                   choice_id,
                                                                                   expired_date,
                                                                                   last_resend_time)
                                                values (@user_id, @token, @otp_code, null,
                                                        dateadd(minute, 5, getutcdate()), getutcdate());

                                                if @@rowcount = 1
                                                    begin
                                                        set @sql_result = 1;
                                                        commit tran;
                                                        select 'OTP has been sent to your email.' as msg
                                                        for json path , without_array_wrapper;
                                                        return;
                                                    end
                                            end
                                    end
                            end
                    end
            end
        rollback tran;
        return;
    end try
    begin catch
        if @@trancount > 0
            rollback tran;
    end catch;
end;
go
*/

------------------------------------------------------------------------------------------------------------------------

create PROCEDURE dbo.sp_sign_up @token VARCHAR(20),
                                @email VARCHAR(100),
                                @password VARCHAR(100),
                                @otp_code VARCHAR(6),
                                @status_code INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @user_id VARCHAR(12), @user_status_id INT, @deleted_date DATETIME, @last_conf_code_token VARCHAR(20), @last_resend_date DATETIME;

    SELECT TOP 1 @user_id = user_id,
                 @user_status_id = user_status_id,
                 @deleted_date = deleted_date
    FROM dbo.user_accounts
    WHERE email = @email
    ORDER BY id DESC;

    SELECT TOP 1 @last_resend_date = last_resend_time,
                 @last_conf_code_token = token
    FROM dbo.confirmation_codes
    WHERE user_id = @user_id
    ORDER BY id DESC;

    IF @user_status_id = 2 AND @last_conf_code_token = @token
        BEGIN
            UPDATE dbo.confirmation_codes
            SET last_resend_time = GETUTCDATE(),
                code             = @otp_code,
                update_date      = GETUTCDATE(),
                expired_date     = DATEADD(MINUTE, 5, GETUTCDATE())
            WHERE token = @token;

            SET @status_code = 200;
            RETURN;
        END

    DECLARE @last_token VARCHAR(20);
    SELECT TOP 1 @last_token = token
    FROM dbo.sessions
    WHERE temp_user_id = @user_id
    ORDER BY id DESC;

    IF @user_status_id = 3 AND DATEDIFF(DAY, @deleted_date, GETUTCDATE()) <= 15
        BEGIN
            IF @last_token = @token
                BEGIN
                    UPDATE dbo.sessions
                    SET update_date        = GETUTCDATE(),
                        temp_password_hash = @password
                    WHERE token = @token;

                    UPDATE dbo.confirmation_codes
                    SET code             = NULL,
                        choice_id        = NULL,
                        update_date      = GETUTCDATE(),
                        expired_date     = DATEADD(MINUTE, 5, GETUTCDATE()),
                        last_resend_time = GETUTCDATE()
                    WHERE token = @token;

                    SET @status_code = 202;
                    RETURN;
                END
        END

    IF @last_resend_date IS NOT NULL AND DATEDIFF(MINUTE, @last_resend_date, GETUTCDATE()) < 10
        BEGIN
            SET @status_code = 429;
            RETURN;
        END

    DECLARE @temp_user_id VARCHAR(12) = (SELECT temp_user_id FROM dbo.sessions WHERE token = @token);

    IF @temp_user_id IS NOT NULL
        BEGIN
            DELETE FROM dbo.confirmation_codes WHERE token = @token;

            UPDATE dbo.sessions SET temp_user_id = NULL WHERE token = @token;

            IF EXISTS (SELECT 1 FROM dbo.user_accounts WHERE user_id = @temp_user_id AND user_status_id = 2)
                BEGIN
                    DELETE FROM dbo.user_roles WHERE user_id = @temp_user_id;
                    DELETE FROM dbo.user_accounts_clients WHERE user_id = @temp_user_id;
                    DELETE FROM dbo.user_accounts WHERE user_id = @temp_user_id;
                END
        END

    BEGIN TRY
        BEGIN TRAN;

        IF @user_status_id = 0
            BEGIN
                SET @status_code = 403;
                ROLLBACK TRAN;
                RETURN;
            END

        IF @user_status_id = 1
            BEGIN
                SET @status_code = 409;
                ROLLBACK TRAN;
                RETURN;
            END

        IF @user_status_id = 2 AND DATEDIFF(MINUTE, @last_resend_date, GETUTCDATE()) >= 10
            BEGIN
                DELETE FROM dbo.confirmation_codes WHERE token = @last_token;

                UPDATE dbo.sessions
                SET temp_user_id = NULL,
                    update_date  = GETUTCDATE()
                WHERE token = @last_token;

                DELETE FROM dbo.user_roles WHERE user_id = @user_id;
                DELETE FROM dbo.user_accounts_clients WHERE user_id = @user_id;
                DELETE FROM dbo.user_accounts WHERE user_id = @user_id;
                SET @user_id = NULL;
            END

        IF @user_status_id = 3 AND DATEDIFF(DAY, @deleted_date, GETUTCDATE()) <= 15
            BEGIN
                DELETE FROM dbo.confirmation_codes WHERE token = @last_token;

                UPDATE dbo.sessions
                SET temp_user_id       = NULL,
                    update_date        = GETUTCDATE(),
                    temp_password_hash = NULL
                WHERE token = @last_token;

                UPDATE dbo.sessions
                SET temp_user_id       = @user_id,
                    update_date        = GETUTCDATE(),
                    temp_password_hash = @password
                WHERE token = @token;

                INSERT INTO dbo.confirmation_codes(user_id, token, code, choice_id, expired_date, last_resend_time)
                VALUES (@user_id, @token, NULL, NULL, DATEADD(MINUTE, 5, GETUTCDATE()), GETUTCDATE());

                SET @status_code = 202;
                COMMIT TRAN;
                RETURN;
            END

        DELETE FROM dbo.confirmation_codes WHERE user_id = @user_id;

        IF @user_id IS NULL OR @user_status_id = 3
            BEGIN
                INSERT INTO dbo.user_accounts (email, password_hash)
                VALUES (@email, @password);

                IF @@ROWCOUNT = 1
                    BEGIN
                        SET @user_id = (SELECT user_id FROM dbo.user_accounts WHERE id = SCOPE_IDENTITY());
                        INSERT INTO dbo.user_accounts_clients(user_id) VALUES (@user_id);
                        INSERT INTO dbo.user_roles(user_id, role_id) VALUES (@user_id, 0);

                        UPDATE dbo.sessions
                        SET temp_user_id = @user_id,
                            update_date  = GETUTCDATE()
                        WHERE token = @token;

                        INSERT INTO dbo.confirmation_codes(user_id, token, code, choice_id, expired_date, last_resend_time)
                        VALUES (@user_id, @token, @otp_code, NULL, DATEADD(MINUTE, 5, GETUTCDATE()), GETUTCDATE());

                        SET @status_code = 200;
                        COMMIT TRAN;
                        RETURN;
                    END
            END
        ROLLBACK TRAN;
        SET @status_code = 500;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        SET @status_code = 500;
    END CATCH;
END;
GO

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_insert_choice_user @token varchar(20),
                                      @otp_code varchar(6),
                                      @choice int
as
begin
    set nocount on;

    declare @user_id varchar(12)=(select temp_user_id from dbo.sessions where token = @token);

    declare @status_id int=(select top 1 user_status_id
                            from dbo.user_accounts
                            where user_id = @user_id
                            order by id desc);

    if @status_id != 3
        begin
            select 'Operation not allowed: account status is not suitable for this action.' as error_msg
            for json path, without_array_wrapper;
            return;
        end

    declare @email varchar(100);


    if exists(select 1
              from dbo.confirmation_codes
              where token = @token)
        begin
            update dbo.confirmation_codes
            set code             = @otp_code,
                choice_id        = @choice,
                update_date      = getutcdate(),
                expired_date     = dateadd(minute, 5, getutcdate()),
                last_resend_time = getutcdate()
            where token = @token;

            if @@rowcount = 1
                begin
                    set @email = (select email from dbo.user_accounts where user_id = @user_id);

                    select @email as user_email
                    for json path, without_array_wrapper;
                end
        end
    else
        begin
            select 'Time has expired. Please refresh and try again.' as error_msg
            for json path ,without_array_wrapper;
        end
end
go;

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_resend_otp_code @token varchar(20),
                                   @otp_code varchar(6)
as
begin
    set nocount on;

    declare @current_time datetime = getutcdate();
    declare @last_resend_time datetime;

    select @last_resend_time = last_resend_time
    from dbo.confirmation_codes
    where token = @token;

    if @last_resend_time is not null and datediff(minute, @last_resend_time, @current_time) < 3
        begin
            select 'You can only resend otp after 3 minutes.' as error_msg
            for json path, without_array_wrapper;
            return;
        end

    if exists(select 1 from dbo.confirmation_codes where token = @token)
        begin
            update dbo.confirmation_codes
            set code             = @otp_code,
                update_date      = getutcdate(),
                expired_date     = dateadd(minute, 5, getutcdate()),
                last_resend_time = getutcdate()
            where token = @token;

            if @@rowcount = 1
                begin
                    select c.user_id as user_id,
                           c.code    as code,
                           u.email   as email
                    from dbo.confirmation_codes c
                             join dbo.user_accounts u on c.user_id = u.user_id
                    where c.token = @token
                    for json path , without_array_wrapper;
                end
        end
    else
        begin
            select 'Time has expired. Please refresh and try again.' as error_msg
            for json path, without_array_wrapper;
            return;
        end
end
go;

------------------------------------------------------------------------------------------------------------------------

/*
create proc dbo.sp_confirm_otp @token varchar(20),
                               @entered_otp_code varchar(6),
                               @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin tran;

        declare @user_id varchar(12), @entered_choice int,@otp_code varchar(6),@expired_date datetime,@user_status_id int,@email varchar(100);

        declare @password_hash varchar(100) = (select temp_password_hash from dbo.sessions where token = @token);

        select @user_id = user_id,
               @otp_code = code,
               @entered_choice = choice_id,
               @expired_date = expired_date
        from dbo.confirmation_codes
        where token = @token;

        select @user_status_id = user_status_id, @email = email from dbo.user_accounts where user_id = @user_id;

        if not exists(select 1 from dbo.confirmation_codes where token = @token)
            begin
                select 'Time has expired.' as error_msg
                for json path ,without_array_wrapper;
                rollback tran;
                return;
            end

        if @expired_date <= getutcdate()
            begin
                select 'Time has expired. Please resend otp code and try again.' as error_msg
                for json path ,without_array_wrapper;
                rollback tran;
                return;
            end

        if @otp_code = @entered_otp_code
            begin
                declare @new_token varchar(20);

                if @user_status_id = 3
                    begin
                        -- Обработка создания нового аккаунта
                        if @entered_choice = 0
                            begin
                                insert into dbo.user_accounts (email, password_hash, user_status_id)
                                values (@email, @password_hash, 1);

                                if @@rowcount = 1
                                    begin
                                        set @user_id = (select user_id from dbo.user_accounts where id = @@identity);
                                        insert into dbo.user_accounts_clients(user_id) values (@user_id);

                                        if @@rowcount = 1
                                            begin
                                                insert into dbo.user_roles(user_id, role_id) values (@user_id, 0);

                                                if @@rowcount = 1
                                                    begin
                                                        delete from dbo.confirmation_codes where token = @token;

                                                        set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                                        update dbo.sessions
                                                        set token=@new_token,
                                                            user_id = @user_id,
                                                            status=1,
                                                            login_date=getutcdate(),
                                                            expired_date=dateadd(hour, 3, getutcdate()),
                                                            update_date = getutcdate()
                                                        where token = @token;

                                                        if @@rowcount = 1
                                                            begin
                                                                select @new_token     as 'token',
                                                                       s.user_id      as 'userID',
                                                                       r.name         as 'role',
                                                                       s.expired_date as 'expiringDate'
                                                                from dbo.sessions s
                                                                         join dbo.user_roles ur on s.user_id = ur.user_id
                                                                         join dbo.roles r on ur.role_id = r.role_id
                                                                where s.token = @new_token
                                                                for json path, without_array_wrapper;

                                                                set @sql_result = 1;
                                                                commit tran;
                                                                return;
                                                            end
                                                    end
                                            end
                                    end
                                rollback tran;
                                return;
                            end

                        -- Обработка восстановления существующего аккаунта
                        if @entered_choice = 1
                            begin
                                update dbo.user_accounts
                                set user_status_id = 1,
                                    password_hash=@password_hash,
                                    update_date    = getutcdate(),
                                    deleted_date   = null
                                where user_id = @user_id;

                                if @@rowcount = 1
                                    begin
                                        delete from dbo.confirmation_codes where token = @token;

                                        set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                        update dbo.sessions
                                        set token        = @new_token,
                                            user_id      = @user_id,
                                            status       = 1,
                                            update_date  = getutcdate(),
                                            login_date   = getutcdate(),
                                            expired_date = dateadd(hour, 3, getutcdate())
                                        where token = @token;

                                        if @@rowcount = 1
                                            begin
                                                select @new_token     as 'token',
                                                       s.user_id      as 'userID',
                                                       r.name         as 'role',
                                                       s.expired_date as 'expiringDate'
                                                from dbo.sessions s
                                                         join dbo.user_roles ur on s.user_id = ur.user_id
                                                         join dbo.roles r on ur.role_id = r.role_id
                                                where s.token = @new_token
                                                for json path, without_array_wrapper;

                                                set @sql_result = 1;
                                                commit tran;
                                                return;
                                            end
                                    end
                                rollback tran;
                                return;
                            end
                    end
                else
                    begin
                        -- Активация аккаунта, если статус равен 2
                        update dbo.user_accounts
                        set user_status_id = 1,
                            update_date    = getutcdate()
                        where user_id = @user_id;

                        if @@rowcount = 1
                            begin
                                delete from dbo.confirmation_codes where token = @token;

                                set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                update dbo.sessions
                                set token        = @new_token,
                                    user_id      = @user_id,
                                    status       = 1,
                                    update_date  = getutcdate(),
                                    login_date   = getutcdate(),
                                    expired_date = dateadd(hour, 3, getutcdate())
                                where token = @token;

                                if @@rowcount = 1
                                    begin
                                        select @new_token     as 'token',
                                               s.user_id      as 'userID',
                                               r.name         as 'role',
                                               s.expired_date as 'expiringDate'
                                        from dbo.sessions s
                                                 join dbo.user_roles ur on s.user_id = ur.user_id
                                                 join dbo.roles r on ur.role_id = r.role_id
                                        where s.token = @new_token
                                        for json path, without_array_wrapper;

                                        set @sql_result = 1;
                                        commit tran;
                                        return;
                                    end
                            end
                        rollback tran;
                        return;
                    end
            end
        else
            begin
                select 'Invalid otp. Please try again.' as error_msg
                for json path ,without_array_wrapper;
            end
        rollback tran;
        return;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback tran;
            end
    end catch;
end
go
*/

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_confirm_otp @token varchar(20),
                               @entered_otp_code varchar(6)
as
begin
    set nocount on;

    begin try
        begin tran;

        declare @user_id varchar(12),
            @entered_choice int,
            @otp_code varchar(6),
            @expired_date datetime,
            @user_status_id int,
            @email varchar(100);

        declare @password_hash varchar(100) = (select temp_password_hash
                                               from dbo.sessions
                                               where token = @token);

        select @user_id = user_id,
               @otp_code = code,
               @entered_choice = choice_id,
               @expired_date = expired_date
        from dbo.confirmation_codes
        where token = @token;

        select @user_status_id = user_status_id,
               @email = email
        from dbo.user_accounts
        where user_id = @user_id;

        if not exists(select 1 from dbo.confirmation_codes where token = @token)
            begin
                rollback tran;
                select 404 as status_code, 'Token not found' as message
                for json path, without_array_wrapper;
                return;
            end

        if @expired_date <= getutcdate()
            begin
                rollback tran;
                select 410 as status_code, 'Time has expired. Please resend otp code and try again.' as message
                for json path, without_array_wrapper;
                return;
            end

        if @otp_code = @entered_otp_code
            begin
                declare @new_token varchar(20);

                if @user_status_id = 3
                    begin
                        if @entered_choice = 0
                            begin
                                insert into dbo.user_accounts (email, password_hash, user_status_id)
                                values (@email, @password_hash, 1);

                                if @@rowcount = 1
                                    begin
                                        set @user_id = (select user_id from dbo.user_accounts where id = @@identity);
                                        insert into dbo.user_accounts_clients(user_id) values (@user_id);

                                        if @@rowcount = 1
                                            begin
                                                insert into dbo.user_roles(user_id, role_id) values (@user_id, 0);

                                                if @@rowcount = 1
                                                    begin
                                                        delete from dbo.confirmation_codes where token = @token;

                                                        set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                                        update dbo.sessions
                                                        set token        = @new_token,
                                                            user_id      = @user_id,
                                                            status       = 1,
                                                            login_date   = getutcdate(),
                                                            expired_date = dateadd(hour, 3, getutcdate()),
                                                            update_date  = getutcdate()
                                                        where token = @token;

                                                        if @@rowcount = 1
                                                            begin
                                                                commit tran;
                                                                select 200            as status_code,
                                                                       @new_token     as token,
                                                                       s.user_id      as userID,
                                                                       r.name         as role,
                                                                       s.expired_date as expiringDate
                                                                from dbo.sessions s
                                                                         join dbo.user_roles ur on s.user_id = ur.user_id
                                                                         join dbo.roles r on ur.role_id = r.role_id
                                                                where s.token = @new_token
                                                                for json path, without_array_wrapper;
                                                                return;
                                                            end
                                                    end
                                            end
                                    end
                                rollback tran;
                                select 500 as status_code, 'Error occurred during account creation.' as message
                                for json path, without_array_wrapper;
                                return;
                            end

                        if @entered_choice = 1
                            begin
                                update dbo.user_accounts
                                set user_status_id = 1,
                                    password_hash  = @password_hash,
                                    update_date    = getutcdate(),
                                    deleted_date   = null
                                where user_id = @user_id;

                                if @@rowcount = 1
                                    begin
                                        delete from dbo.confirmation_codes where token = @token;

                                        set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                        update dbo.sessions
                                        set token        = @new_token,
                                            user_id      = @user_id,
                                            status       = 1,
                                            update_date  = getutcdate(),
                                            login_date   = getutcdate(),
                                            expired_date = dateadd(hour, 3, getutcdate())
                                        where token = @token;

                                        if @@rowcount = 1
                                            begin
                                                commit tran;
                                                select 200            as status_code,
                                                       @new_token     as token,
                                                       s.user_id      as userID,
                                                       r.name         as role,
                                                       s.expired_date as expiringDate
                                                from dbo.sessions s
                                                         join dbo.user_roles ur on s.user_id = ur.user_id
                                                         join dbo.roles r on ur.role_id = r.role_id
                                                where s.token = @new_token
                                                for json path, without_array_wrapper;
                                                return;
                                            end
                                    end
                                rollback tran;
                                select 500 as status_code, 'Error occurred during account recovery.' as message
                                for json path, without_array_wrapper;
                                return;
                            end
                    end
                else
                    begin
                        update dbo.user_accounts
                        set user_status_id = 1,
                            update_date    = getutcdate()
                        where user_id = @user_id;

                        if @@rowcount = 1
                            begin
                                delete from dbo.confirmation_codes where token = @token;

                                set @new_token = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                update dbo.sessions
                                set token        = @new_token,
                                    user_id      = @user_id,
                                    status       = 1,
                                    update_date  = getutcdate(),
                                    login_date   = getutcdate(),
                                    expired_date = dateadd(hour, 3, getutcdate())
                                where token = @token;

                                if @@rowcount = 1
                                    begin
                                        commit tran;
                                        select 200            as status_code,
                                               @new_token     as token,
                                               s.user_id      as userID,
                                               r.name         as role,
                                               s.expired_date as expiringDate
                                        from dbo.sessions s
                                                 join dbo.user_roles ur on s.user_id = ur.user_id
                                                 join dbo.roles r on ur.role_id = r.role_id
                                        where s.token = @new_token
                                        for json path, without_array_wrapper;
                                        return;
                                    end
                            end
                        rollback tran;
                        select 500 as status_code, 'Error occurred during account activation.' as message
                        for json path, without_array_wrapper;
                        return;
                    end
            end
        else
            begin
                rollback tran;
                select 401 as status_code, 'Invalid OTP. Please try again.' as message
                for json path, without_array_wrapper;
                return;
            end
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback tran;
            end
        select 500 as status_code, 'An unexpected error occurred.' as message
        for json path, without_array_wrapper;
    end catch;
end
go

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.sp_sign_in @token varchar(20),
                                @email varchar(100),
                                @password varchar(100),
                                @otp_code varchar(6)=null,
                                @remember_me bit,
                                @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @temp_user_id varchar(12)=(select temp_user_id from dbo.sessions where token = @token);

        declare @user_id varchar(12),@user_status_id int, @deleted_date datetime,@user_pass varchar(100);
        declare @last_token varchar(20), @last_resend_date datetime;

        select top 1 @user_id = user_id,
                     @user_pass = password_hash,
                     @user_status_id = user_status_id,
                     @deleted_date = deleted_date
        from dbo.user_accounts
        where email = @email
        order by id desc;

        declare @role_id int = (select role_id from dbo.user_roles where user_id = @user_id);

        select @last_resend_date = last_resend_time, @last_token = token
        from dbo.confirmation_codes
        where user_id = @user_id;

        if @user_id is null or @user_status_id = 2
            begin
                rollback;
                select 'Not found.' as error_msg for json path, without_array_wrapper;
                return;
            end

        if @user_status_id = 0
            begin
                select 'This account is blocked.' AS error_msg
                for json path , without_array_wrapper;
                rollback tran;
                return;
            end

        if @user_status_id = 1 and @user_pass != @password
            begin
                rollback;
                select 'Incorrect password.' as error_msg for json path, without_array_wrapper;
                return;
            end

        if @user_status_id = 3
            begin
                rollback;
                select 'Account deleted.' as error_msg for json path, without_array_wrapper;
                return;
            end

        -- Если роль админ
        if @role_id = 1
            begin
                if @last_token = @token
                    begin
                        update dbo.confirmation_codes
                        set code             = @otp_code,
                            update_date      = getutcdate(),
                            expired_date     = dateadd(minute, 5, getutcdate()),
                            last_resend_time = getutcdate()
                        where token = @token;

                        update dbo.sessions
                        set remember_me = @remember_me,
                            temp_user_id=null,
                            update_date = getutcdate()
                        where token = @token;

                        select 'OTP has been sent to your email.' as msg for json path, without_array_wrapper;
                        set @sql_result = 1;
                        commit;
                        return;
                    end

                if @last_resend_date is not null and datediff(minute, @last_resend_date, getutcdate()) < 5
                    begin
                        rollback;
                        select 'The process with this account is already in progress. Please try again later.' as error_msg
                        for json path, without_array_wrapper;
                        return;
                    end

                delete from dbo.confirmation_codes where token = @last_token;

                update dbo.sessions
                set remember_me=null,
                    temp_user_id=null,
                    update_date=getutcdate()
                where token = @last_token;

                update dbo.sessions
                set remember_me = @remember_me,
                    temp_user_id=@user_id,
                    update_date = getutcdate()
                where token = @token;


                if @temp_user_id is not null
                    begin
                        delete from dbo.confirmation_codes where token = @token;
                        if exists (select 1 from dbo.user_accounts where user_id = @temp_user_id and user_status_id = 2)
                            begin
                                delete from dbo.user_roles where user_id = @temp_user_id;
                                delete from dbo.user_accounts_clients where user_id = @temp_user_id;
                                delete from dbo.user_accounts where user_id = @temp_user_id;
                            end
                    end

                insert into dbo.confirmation_codes (user_id, token, code, choice_id, expired_date, last_resend_time)
                values (@user_id, @token, @otp_code, null, dateadd(minute, 5, getutcdate()), getutcdate());

                select 'OTP has been sent to your email.' as msg for json path, without_array_wrapper;
                set @sql_result = 1;
                commit;
                return;
            end

        -- Если роль клиент
        declare @new_token varchar(20) = lower(convert(varchar(20), crypt_gen_random(10), 2));

        delete from dbo.confirmation_codes where token = @token;
        --delete from dbo.confirmation_codes where user_id = @user_id;

        update dbo.sessions
        set token=@new_token,
            temp_user_id=@user_id,
            remember_me_token = case
                                    when @remember_me = 1
                                        then lower(convert(varchar(64), crypt_gen_random(32), 2)) end,
            remember_me = @remember_me,
            remember_me_expiration = case when @remember_me = 1 then dateadd(day, 7, getutcdate()) end,
            expired_date=dateadd(hour, 3, getutcdate()),
            user_id = @user_id,
            status = 1,
            login_date = getutcdate(),
            update_date = getutcdate()
        where token = @token;

        if @temp_user_id is not null
            begin
                if exists (select 1 from dbo.user_accounts where user_id = @temp_user_id and user_status_id = 2)
                    begin
                        delete from dbo.user_roles where user_id = @temp_user_id;
                        delete from dbo.user_accounts_clients where user_id = @temp_user_id;
                        delete from dbo.user_accounts where user_id = @temp_user_id;
                    end
            end
        select token, user_id, 'client' as role, expired_date
        from dbo.sessions
        where token = @new_token
        for json auto, without_array_wrapper;
        set @sql_result = 1;
        commit;
        return;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback;
            end
    end catch;
end
go
*/

------------------------------------------------------------------------------------------------------------------------

create procedure dbo.sp_sign_in @token varchar(20),
                                @email varchar(100),
                                @otp_code varchar(6) = null,
                                @remember_me bit
as
begin
    set nocount on;

    begin try
        begin transaction;

        declare @temp_user_id varchar(12) = (select temp_user_id from dbo.sessions where token = @token);
        declare @user_id varchar(12), @user_status_id int, @deleted_date datetime, @user_pass varchar(100);
        declare @last_token varchar(20), @last_resend_date datetime;

        select top 1 @user_id = user_id,
                     @user_pass = password_hash,
                     @user_status_id = user_status_id,
                     @deleted_date = deleted_date
        from dbo.user_accounts
        where email = @email
        order by id desc;

        declare @role_id int = (select role_id from dbo.user_roles where user_id = @user_id);

        select @last_resend_date = last_resend_time,
               @last_token = token
        from dbo.confirmation_codes
        where user_id = @user_id;

        if @user_id is null or @user_status_id = 2
            begin
                rollback;
                select 404 as status, 'Not found.' as message for json path, without_array_wrapper;
                return;
            end

        if @user_status_id = 0
            begin
                rollback;
                select 403 as status, 'This account is blocked.' as message
                for json path, without_array_wrapper;
                return;
            end

        if @user_status_id = 3
            begin
                rollback;
                select 410 as status, 'Account deleted.' as message for json path, without_array_wrapper;
                return;
            end

        if @role_id = 1
            begin
                if @last_token = @token
                    begin
                        update dbo.confirmation_codes
                        set code             = @otp_code,
                            update_date      = getutcdate(),
                            expired_date     = dateadd(minute, 5, getutcdate()),
                            last_resend_time = getutcdate()
                        where token = @token;

                        update dbo.sessions
                        set remember_me  = @remember_me,
                            temp_user_id = null,
                            update_date  = getutcdate()
                        where token = @token;

                        select              202                                as status,
                                            'OTP has been sent to your email.' as message,
                            password_hash = @user_pass
                        for json path, without_array_wrapper;
                        commit;
                        return;
                    end

                if @last_resend_date is not null and datediff(minute, @last_resend_date, getutcdate()) < 5
                    begin
                        rollback;
                        select 429                                                                             as status,
                               'The process with this account is already in progress. Please try again later.' as message
                        for json path, without_array_wrapper;
                        return;
                    end

                delete from dbo.confirmation_codes where token = @last_token;

                update dbo.sessions
                set remember_me  = null,
                    temp_user_id = null,
                    update_date  = getutcdate()
                where token = @last_token;

                update dbo.sessions
                set remember_me  = @remember_me,
                    temp_user_id = @user_id,
                    update_date  = getutcdate()
                where token = @token;

                if @temp_user_id is not null
                    begin
                        delete from dbo.confirmation_codes where token = @token;
                        if exists (select 1
                                   from dbo.user_accounts
                                   where user_id = @temp_user_id
                                     and user_status_id = 2)
                            begin
                                delete from dbo.user_roles where user_id = @temp_user_id;
                                delete from dbo.user_accounts_clients where user_id = @temp_user_id;
                                delete from dbo.user_accounts where user_id = @temp_user_id;
                            end
                    end

                insert into dbo.confirmation_codes (user_id, token, code, choice_id, expired_date, last_resend_time)
                values (@user_id, @token, @otp_code, null, dateadd(minute, 5, getutcdate()), getutcdate());

                select              202                                as status,
                                    'OTP has been sent to your email.' as message,
                    password_hash = @user_pass
                for json path, without_array_wrapper;
                commit;
                return;
            end

        -- Логика для роли клиента
        declare @new_token varchar(20) = lower(convert(varchar(20), crypt_gen_random(10), 2));

        delete from dbo.confirmation_codes where token = @token;

        update dbo.sessions
        set token                  = @new_token,
            temp_user_id           = @user_id,
            remember_me_token      = case
                                         when @remember_me = 1
                                             then lower(convert(varchar(64), crypt_gen_random(32), 2))
                end,
            remember_me            = @remember_me,
            remember_me_expiration = case
                                         when @remember_me = 1 then dateadd(day, 7, getutcdate())
                end,
            expired_date           = dateadd(hour, 3, getutcdate()),
            user_id                = @user_id,
            status                 = 1,
            login_date             = getutcdate(),
            update_date            = getutcdate()
        where token = @token;

        if @temp_user_id is not null
            begin
                if exists (select 1 from dbo.user_accounts where user_id = @temp_user_id and user_status_id = 2)
                    begin
                        delete from dbo.user_roles where user_id = @temp_user_id;
                        delete from dbo.user_accounts_clients where user_id = @temp_user_id;
                        delete from dbo.user_accounts where user_id = @temp_user_id;
                    end
            end

        select              200 as status,
            token         = @new_token,
            user_id       = @user_id,
            role          = 'client',
            expired_date  = dateadd(hour, 3, getutcdate()),
            password_hash = @user_pass
        for json path, without_array_wrapper;
        commit;
        return;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback;
            end
        select 500 as status, 'An unexpected error occurred.' as message for json path, without_array_wrapper;
    end catch;
end
go

------------------------------------------------------------------------------------------------------------------------

create proc dbo.sp_refresh_token @remember_me_token varchar(64)
as
begin
    set nocount on;
    begin try
        begin tran
            declare @token varchar(20), @user_id varchar(12), @remember_me_expiration datetime;

            select @token = token, @user_id = user_id, @remember_me_expiration = remember_me_expiration
            from dbo.sessions
            where remember_me_token = @remember_me_token
              and remember_me_expiration > getutcdate();

            if @user_id is not null
                begin
                    declare @new_token varchar(20) = lower(convert(varchar(20), crypt_gen_random(10), 2));

                    update dbo.sessions
                    set token        = @new_token,
                        status=1,
                        update_date  = getutcdate(),
                        expired_date = dateadd(hour, 3, getutcdate())
                    where token = @token;

                    if datediff(day, getutcdate(), @remember_me_expiration) < 3
                        begin
                            declare @new_remember_me_token varchar(64) = lower(convert(varchar(64), crypt_gen_random(32), 2));

                            update dbo.sessions
                            set remember_me_token      = @new_remember_me_token,
                                remember_me_expiration = dateadd(day, 7, getutcdate()),
                                update_date            = getutcdate()
                            where token = @new_token;
                        end

                    select @new_token                                                                  as 'token',
                           user_id                                                                     as userID,
                           (select name
                            from dbo.roles
                            where role_id = (select role_id from user_roles where user_id = @user_id)) as 'role',
                           expired_date                                                                as 'expiringDate'
                    from dbo.sessions
                    where token = @new_token
                    for json auto, without_array_wrapper;
                end
            else
                begin
                    select null as 'result', 404 as 'status_code' for json path, without_array_wrapper;
                end
        commit tran;
    end try
    begin catch
        if @@trancount > 0
            rollback;
        throw;
    end catch;
end;
go;

------------------------------------------------------------------------------------------------------------------------

/*
create procedure dbo.sp_forgot_password @token varchar(20),
                                        @email varchar(100),
                                        @otp_code varchar(6),
                                        @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    declare @user_id varchar(12),@user_status_id int,@last_resend_date datetime,@last_token varchar(20);

    select top 1 @user_id = user_id,
                 @user_status_id = user_status_id
    from dbo.user_accounts
    where email = @email
    order by id desc;

    select @last_resend_date = last_resend_time, @last_token = token
    from dbo.confirmation_codes
    where user_id = @user_id;

    declare @role_id int = (select role_id from dbo.user_roles where user_id = @user_id);

    if @user_id is null or @user_status_id = 2
        begin
            select 'Not found.' as error_msg for json path, without_array_wrapper;
            return;
        end

    if @user_status_id = 0
        begin
            select 'This account is blocked.' AS error_msg for json path , without_array_wrapper;
            return;
        end

    if @user_status_id = 1
        begin
            if @role_id = 1
                begin
                    select 'Forbidden.' as error_msg for json path, without_array_wrapper;
                    return;
                end
            else
                begin
                    if @last_token = @token
                        begin
                            update dbo.confirmation_codes
                            set code             = @otp_code,
                                update_date      = getutcdate(),
                                expired_date     = dateadd(minute, 5, getutcdate()),
                                last_resend_time = getutcdate()
                            where token = @token;
                            select 'OTP has been sent to your email.' as msg for json path, without_array_wrapper;
                            set @sql_result = 1;
                            return;
                        end

                    if @last_resend_date is not null and datediff(minute, @last_resend_date, getutcdate()) < 5
                        begin
                            select 'The process with this account is already in progress. Please try again later.' as error_msg
                            for json path, without_array_wrapper;
                            return;
                        end

                    delete from dbo.confirmation_codes where user_id = @user_id;

                    insert into dbo.confirmation_codes (user_id, token, code, choice_id, expired_date, last_resend_time)
                    values (@user_id, @token, @otp_code, null, dateadd(minute, 5, getutcdate()), getutcdate());

                    if @@rowcount = 1
                        begin
                            select 'OTP has been sent to your email.' as msg for json path, without_array_wrapper;
                            set @sql_result = 1;
                            return;
                        end
                end
        end

    if @user_status_id = 3
        begin
            select 'Account deleted.' as error_msg for json path, without_array_wrapper;
        end
end
go
*/

------------------------------------------------------------------------------------------------------------------------

alter procedure dbo.sp_forgot_password @token varchar(20),
                                       @email varchar(100),
                                       @otp_code varchar(6)
as
begin
    set nocount on;

    declare @user_id varchar(12), @user_status_id int, @last_resend_date datetime, @last_token varchar(20);

    select top 1 @user_id = user_id,
                 @user_status_id = user_status_id
    from dbo.user_accounts
    where email = @email
    order by id desc;

    select @last_resend_date = last_resend_time,
           @last_token = token
    from dbo.confirmation_codes
    where user_id = @user_id;

    declare @role_id int = (select role_id from dbo.user_roles where user_id = @user_id);

    if @user_id is null
        begin
            select 'Not found.' as error_msg, 404 as status_code for json path, without_array_wrapper;
            return;
        end

    if @user_status_id in (0, 2, 3)
        begin
            declare @msg varchar(50);
            if @user_status_id = 0 set @msg = 'This account is blocked.';
            if @user_status_id = 2 set @msg = 'Not found.';
            if @user_status_id = 3 set @msg = 'Account deleted.';
            select @msg as error_msg, 403 as status_code for json path, without_array_wrapper;
            return;
        end

    if @role_id = 1
        begin
            select 'Forbidden.' as error_msg, 403 as status_code for json path, without_array_wrapper;
            return;
        end

    if @last_resend_date is not null and datediff(minute, @last_resend_date, getutcdate()) < 5
        begin
            select 'The process with this account is already in progress. Please try again later.' as error_msg,
                   429                                                                             as status_code
            for json path, without_array_wrapper;
            return;
        end

    if @last_token = @token
        begin
            update dbo.confirmation_codes
            set code             = @otp_code,
                update_date      = getutcdate(),
                expired_date     = dateadd(minute, 5, getutcdate()),
                last_resend_time = getutcdate()
            where token = @token;

            select 'OTP has been sent to your email.' as msg, 200 as status_code for json path, without_array_wrapper;
            return;
        end

    merge dbo.confirmation_codes as target
    using (select @user_id as user_id) as source
    on target.user_id = source.user_id
    when matched then
        update
        set code             = @otp_code,
            update_date      = getutcdate(),
            expired_date     = dateadd(minute, 5, getutcdate()),
            last_resend_time = getutcdate()
    when not matched then
        insert (user_id, token, code, choice_id, expired_date, last_resend_time)
        values (@user_id, @token, @otp_code, null, dateadd(minute, 5, getutcdate()), getutcdate());

    select 'OTP has been sent to your email.' as msg, 200 as status_code for json path, without_array_wrapper;
end;
go


------------------------------------------------------------------------------------------------------------------------

/*
alter proc dbo.sp_forgot_password_confirm_otp @token varchar(20),
                                              @entered_otp_code varchar(6),
                                              @new_password varchar(100),
                                              @sql_result bit output
as
begin
    set nocount on;
    set @sql_result = 0;

    begin try
        begin transaction;

        declare @user_id varchar(12), @otp_code varchar(6),@expired_date datetime,@user_status_id int;

        --проверить, нужен ли top 1
        select @user_id = user_id,
               @otp_code = code,
               @expired_date = expired_date
        from dbo.confirmation_codes
        where token = @token;

        select @user_status_id = user_status_id from dbo.user_accounts where user_id = @user_id;

        if @expired_date <= getutcdate()
            begin
                select 'Time has expired. Please resend otp code and try again.' as error_msg
                for json path ,without_array_wrapper;
                rollback tran;
                return;
            end

        if @user_status_id = 1
            begin
                if @otp_code = @entered_otp_code
                    begin
                        update dbo.user_accounts
                        set password_hash = @new_password,
                            update_date   = getutcdate()
                        where user_id = @user_id;

                        if @@rowcount = 1
                            begin
                                delete from dbo.confirmation_codes where token = @token;
                                update dbo.sessions set status=0 where user_id = @user_id;

                                declare @new_token varchar(20) = lower(convert(varchar(20), crypt_gen_random(10), 2));

                                update dbo.sessions
                                set token        = @new_token,
                                    user_id      = @user_id,
                                    status       = 1,
                                    update_date  = getutcdate(),
                                    login_date   = getutcdate(),
                                    expired_date = dateadd(hour, 3, getutcdate())
                                where token = @token;

                                if @@rowcount = 1
                                    begin
                                        set @sql_result = 1;

                                        select @new_token                                                                  as 'token',
                                               user_id                                                                     as user_id,
                                               (select name
                                                from dbo.roles
                                                where role_id = (select role_id from user_roles where user_id = @user_id)) as 'role',
                                               expired_date                                                                as 'expired_date'
                                        from dbo.sessions
                                        where token = @new_token
                                        for json auto, without_array_wrapper;
                                        commit transaction;
                                        return;
                                    end
                            end
                    end
            end
        rollback tran;
    end try
    begin catch
        if @@trancount > 0
            begin
                rollback tran ;
            end
    end catch;
end;
go;
 */

------------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE dbo.sp_forgot_password_confirm_otp @token VARCHAR(20),
                                                   @entered_otp_code VARCHAR(6),
                                                   @new_password VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @user_id VARCHAR(12),
            @otp_code VARCHAR(6),
            @expired_date DATETIME,
            @user_status_id INT;

        SELECT @user_id = user_id,
               @otp_code = code,
               @expired_date = expired_date
        FROM dbo.confirmation_codes
        WHERE token = @token;

        SELECT @user_status_id = user_status_id
        FROM dbo.user_accounts
        WHERE user_id = @user_id;

        IF @expired_date <= GETUTCDATE()
            BEGIN
                SELECT JSON_QUERY('{"error_msg": "Time has expired. Please resend otp code and try again."}') AS result;
                ROLLBACK TRAN;
                RETURN;
            END

        IF @user_status_id = 1 AND @otp_code = @entered_otp_code
            BEGIN
                UPDATE dbo.user_accounts
                SET password_hash = @new_password,
                    update_date   = GETUTCDATE()
                WHERE user_id = @user_id;

                IF @@ROWCOUNT = 1
                    BEGIN
                        DELETE
                        FROM dbo.confirmation_codes
                        WHERE token = @token;

                        UPDATE dbo.sessions
                        SET status = 0
                        WHERE user_id = @user_id;

                        DECLARE @new_token VARCHAR(20) = LOWER(CONVERT(VARCHAR(20), CRYPT_GEN_RANDOM(10), 2));

                        UPDATE dbo.sessions
                        SET token        = @new_token,
                            user_id      = @user_id,
                            status       = 1,
                            update_date  = GETUTCDATE(),
                            login_date   = GETUTCDATE(),
                            expired_date = DATEADD(HOUR, 3, GETUTCDATE())
                        WHERE token = @token;

                        IF @@ROWCOUNT = 1
                            BEGIN
                                SELECT JSON_QUERY(
                                               CONCAT(
                                                       '{"token":"', @new_token, '",',
                                                       '"user_id":"', @user_id, '",',
                                                       '"role":"', (SELECT name
                                                                    FROM dbo.roles
                                                                    WHERE role_id = (SELECT role_id FROM user_roles WHERE user_id = @user_id)),
                                                       '",',
                                                       '"expired_date":"', CONVERT(VARCHAR(25), GETUTCDATE(), 127), '"}'
                                               )
                                       ) AS result;

                                COMMIT TRAN;
                                RETURN;
                            END
                    END
            END

        SELECT JSON_QUERY('{"error_msg": "Invalid OTP or operation failed."}') AS result;
        ROLLBACK TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRAN;
            END
        SELECT JSON_QUERY('{"error_msg": "An unexpected error occurred."}') AS result;
    END CATCH;
END;
GO

------------------------------------------------------------------------------------------------------------------------

alter procedure dbo.sp_logout @token varchar(20),
                              @sql_result bit output
as
begin
    set nocount on;

    update dbo.sessions
    set status      = 0,
        update_date=getutcdate(),
        logout_date = getutcdate()
    where token = @token

    set @sql_result = IIF(@@rowcount = 1, 1, 0);
    return;
end
go
