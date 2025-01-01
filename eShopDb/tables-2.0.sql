use eCommerceDb
------------------------------------------------------------------------------------------------------------------------

create table dbo.platforms
(
    id           int identity (1,1),
    platform_key varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    [name]       varchar(10) not null,
    status       bit                     default 1,
    update_date  datetime                default getutcdate()
)

insert into dbo.platforms([name])
values ('web'),
       ('mobile')

select *
from dbo.platforms

------------------------------------------------------------------------------------------------------------------------

create table dbo.locations
(
    id          int identity (1,1),
    location_id varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    name        varchar(30) not null,
    type        varchar(10) check (type in ('Country', 'State', 'Province', 'Region')),
    parent_id   varchar(6) foreign key references dbo.locations (location_id),
    update_date datetime               default getutcdate()
)

select *
from dbo.locations

insert into dbo.locations(name, type)
values ('USA', 'Country'),
       ('Canada', 'Country'),
       ('Russia', 'Country');

insert into dbo.locations(name, type, parent_id)
values ('California', 'State', (select location_id from dbo.locations where name = 'USA')),
       ('Texas', 'State', (select location_id from dbo.locations where name = 'USA'))

insert into dbo.locations(name, type, parent_id)
values ('Moscow Region', 'Region', (select location_id from dbo.locations where name = 'Russia')),
       ('Saint Petersburg', 'Region', (select location_id from dbo.locations where name = 'Russia'));

insert into dbo.locations(name, type, parent_id)
values ('Ontario', 'Province', (select location_id from dbo.locations where name = 'Canada')),
       ('Quebec', 'Province', (select location_id from dbo.locations where name = 'Canada'));

select l.name
from dbo.locations l
         join dbo.locations c ON l.parent_id = c.location_id
where c.name = 'Canada'


------------------------------------------------------------------------------------------------------------------------

create table dbo.roles
(
    id          int identity (1,1),
    role_id     int primary key,
    [name]      varchar(15) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

insert into dbo.roles(role_id, [name])
values (0, 'Client'),
       (1, 'Admin')

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_statuses
(
    status_id   int primary key,
    status_name varchar(50) not null,
    update_date datetime default getutcdate()
)

insert into dbo.user_statuses (status_id, status_name)
values (0, 'blocked'),
       (1, 'active'),
       (2, 'unverified'),
       (3, 'removed')

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_accounts
(
    id             int identity (1,1),
    user_id        varchar(12) primary key                                                    default lower(left(replace(newid(), '-', ''), 12)),
    email          varchar(100) not null,
    password_hash  varchar(100) not null,
    name           varchar(50),
    surname        varchar(50),
    user_status_id int          not null foreign key references dbo.user_statuses (status_id) default 2,
    created_date   datetime                                                                   default getutcdate(),
    update_date    datetime                                                                   default getutcdate(),
    deleted_date   datetime
)
create index ix_user_accounts_email
    on dbo.user_accounts (email);

------------------------------------------------------------------------------------------------------------------------

create table dbo.session_statuses
(
    status_id   int primary key,
    status_name varchar(50) not null,
    update_date datetime default getutcdate()
)

insert into dbo.session_statuses (status_id, status_name)
values (0, 'terminated'),
       (1, 'active'),
       (2, 'pending'),
       (3, 'blocked')

------------------------------------------------------------------------------------------------------------------------

create table dbo.sessions
(
    id                     int identity (1,1),
    token                  varchar(20) primary key                                  default lower(convert(varchar(20), crypt_gen_random(10), 2)),
    remember_me_token      varchar(64),
    user_id                varchar(12) foreign key references dbo.user_accounts (user_id),
    platform_id            varchar(12) foreign key references dbo.platforms (platform_key),
    status                 int not null foreign key references dbo.session_statuses default 2,
    remember_me            bit                                                      default 0,
    created_date           datetime                                                 default getutcdate(),
    update_date            datetime                                                 default getutcdate(),
    login_date             datetime,
    logout_date            datetime,
    expired_date           datetime,
    remember_me_expiration datetime,
    temp_password_hash     varchar(100),
    temp_user_id           varchar(12) foreign key references dbo.user_accounts (user_id),
)

create index ix_sessions_token
    on dbo.sessions (token);

create index ix_sessions_temp_user_id
    on dbo.sessions (temp_user_id);

------------------------------------------------------------------------------------------------------------------------

create table dbo.choices
(
    id          int primary key identity (1,1),
    choice      bit         not null,
    name        varchar(25) not null,
    update_date datetime default getutcdate()
);

insert into dbo.choices(choice, name)
values (0, 'new'),
       (1, 'restore')

------------------------------------------------------------------------------------------------------------------------

create table dbo.confirmation_codes
(
    id               int identity (1,1),
    user_id          varchar(12) not null foreign key references dbo.user_accounts (user_id),
    token            varchar(20) not null foreign key references dbo.sessions (token),
    code             varchar(6),
    choice_id        int foreign key references dbo.choices (id),
    update_date      datetime default getutcdate(),
    expired_date     datetime,
    last_resend_time datetime
);
create index ix_confirmation_codes_user_id
    on dbo.confirmation_codes (user_id);

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_accounts_clients
(
    id           int identity (1,1),
    user_id      varchar(12) not null foreign key references dbo.user_accounts (user_id),
    phone_number varchar(12),
    birth_date   date,
    country_id   varchar(6) foreign key references dbo.locations (location_id),
    location_id  varchar(6) foreign key references dbo.locations (location_id),
    city         varchar(50),
    zip_code     varchar(5),
    update_date  datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_accounts_admins
(
    id          int identity (1,1),
    user_id     varchar(12) not null foreign key references dbo.user_accounts (user_id),
    update_date datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_roles
(
    id          int identity (1,1),
    user_id     varchar(12) not null foreign key references dbo.user_accounts (user_id),
    role_id     int         not null foreign key references dbo.roles (role_id),
    update_date datetime default getutcdate()
        constraint user_role primary key clustered (user_id, role_id)
)

------------------------------------------------------------------------------------------------------------------------

create type dbo.color_list as table
(
    value varchar(7)
);


------------------------------------------------------------------------------------------------------------------------

create table dbo.clothing_colors
(
    id          int identity (1,1),
    code        varchar(7) primary key,
    [name]      nvarchar(25) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

insert into dbo.clothing_colors (code, [name])
values ('#6c6377', 'Dark Purple'),
       ('#fbe9d2', 'Peach Puff'),
       ('#ffbe98', 'Light Coral'),
       ('#131c31', 'Dark Midnight Blue'),
       ('#08a4a7', 'Teal'),
       ('#f67c41', 'Orange Red'),
       ('#416aa3', 'Steel Blue'),
       ('#FFA07A', 'Light Salmon'),
       ('#a52a2a', 'Brown'),
       ('#b3b7bf', 'Light Slate Gray'),
       ('#ff4500', 'Orange Red'),
       ('#8a2be2', 'Blue Violet'),
       ('#ff0000', 'Red'),
       ('#00ff00', 'Green'),
       ('#0000ff', 'Blue'),
       ('#ffff00', 'Yellow'),
       ('#00ffff', 'Cyan'),
       ('#ff00ff', 'Magenta'),
       ('#000000', 'Black'),
       ('#ffffff', 'White'),
       ('#808080', 'Gray'),
       ('#800000', 'Maroon'),
       ('#008000', 'Dark Green'),
       ('#000080', 'Navy'),
       ('#808000', 'Olive'),
       ('#800080', 'Purple'),
       ('#008080', 'Teal');


------------------------------------------------------------------------------------------------------------------------

create table dbo.main_categories
(
    id          int primary key identity (1,1),
    [name]      varchar(15) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

insert into dbo.main_categories(id, [name])
values (11, 'Men'),
       (12, 'Women'),
       (13, 'Kids')

------------------------------------------------------------------------------------------------------------------------

create table dbo.categories
(
    id          int primary key identity (1,1),
    [name]      varchar(25) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

insert into dbo.categories(id, name)
values (1, 'Shoes'),
       (2, 'Clothing')


------------------------------------------------------------------------------------------------------------------------

create type dbo.main_category_id_list as table
(
    main_category_id int
);
go;

------------------------------------------------------------------------------------------------------------------------

create type dbo.sub_category_id_list as table
(
    sub_category_id int
);
go;

------------------------------------------------------------------------------------------------------------------------

create table dbo.sub_categories
(
    id          int primary key identity (1,1),
    category_id int         not null foreign key references dbo.categories (id),
    [name]      varchar(25) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.main_category_sub_category_links
(
    id               int primary key identity (1,1),
    main_category_id int not null foreign key references dbo.main_categories (id),
    category_id      int not null foreign key references dbo.categories (id),
    sub_category_id  int not null foreign key references dbo.sub_categories (id),
    status           bit      default 1,
    update_date      datetime default getutcdate()
        unique (main_category_id, category_id, sub_category_id)
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.clothing_genders
(
    id          int primary key identity (1,1),
    name        varchar(20) not null,
    status      bit      default 1,
    update_date datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create type dbo.gender_list as table
(
    value int
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.products
(
    id                 int identity (1,1),
    product_id         varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    main_category_id   int         not null foreign key references dbo.main_categories (id),
    sub_category_id    int         not null foreign key references dbo.sub_categories (id),
    [name]             varchar(50) not null,
    clothing_gender_id int foreign key references dbo.clothing_genders (id),
    status             bit                     default 1,
    update_date        datetime                default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_variations
(
    id             int identity (1,1),
    variation_code varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    product_id     varchar(12) not null foreign key references dbo.products (product_id),
    status         bit                    default 1,
    update_date    datetime               default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_variation_details
(
    id                   int identity (1,1),
    product_variation_id varchar(6) primary key foreign key references dbo.product_variations (variation_code),
    make                 varchar(25)    not null,
    fabric               varchar(25)    not null,
    description          varchar(200),
    color_id             varchar(7)     not null foreign key references dbo.clothing_colors (code),
    price                decimal(10, 2) not null,
    update_date          datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.sort_types
(
    id   int primary key identity (1,1),
    name varchar(50) not null
);

insert into dbo.sort_types (name)
values ('newest'),
       ('price-high-low'),
       ('price-low-high');

------------------------------------------------------------------------------------------------------------------------

create table dbo.price_ranges
(
    id          int identity (1,1) primary key,
    min_price   decimal(10, 2) not null,
    max_price   decimal(10, 2) null,
    range_label nvarchar(50)   not null
);

insert into dbo.price_ranges (min_price, max_price, range_label)
values (0, 25, '$0-$25'),
       (25, 50, '$25-$50'),
       (50, 100, '$50-$100'),
       (100, 150, '$100-$150'),
       (150, null, 'Over $150');

------------------------------------------------------------------------------------------------------------------------

create table dbo.sizes
(
    id   int primary key identity (1,1),
    size varchar(5) unique
);

------------------------------------------------------------------------------------------------------------------------

create type dbo.size_list as table
(
    size varchar(5)
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_variation_sizes
(
    product_variation_id varchar(6) not null foreign key references dbo.product_variations (variation_code),
    size_id              int        not null foreign key references dbo.sizes (id),
    status               bit default 1
        primary key (product_variation_id, size_id)
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.inventory
(
    id                    int identity (1,1),
    product_variations_id varchar(6) not null foreign key references dbo.product_variations (variation_code),
    quantity              smallint   not null
);

------------------------------------------------------------------------------------------------------------------------

create type dbo.image_url_list as table
(
    image_url varchar(255)
);

------------------------------------------------------------------------------------------------------------------------

create type dbo.image_id_list as table
(
    image_id varchar(6)
);
go

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_images
(
    id                   int identity (1,1),
    image_id             varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    product_variation_id varchar(6) not null foreign key references dbo.product_variations (variation_code),
    url                  varchar(255),
    status               bit                    default 1,
    update_date          datetime               default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.promo_codes
(
    id            int identity (1,1),
    promo_code_id varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    description   varchar(50),
    discount      decimal(5, 2) not null check (discount >= 0 and discount <= 100),
    start_date    datetime      not null,
    end_date      datetime      not null,
    status        bit                    default 1,
    update_date   datetime               default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.main_category_discounts
(
    id               int identity (1,1),
    main_category_id int        not null foreign key references dbo.main_categories (id),
    promo_code_id    varchar(6) not null foreign key references dbo.promo_codes (promo_code_id),
    update_date      datetime default getutcdate(),
    status           bit      default 1
)
------------------------------------------------------------------------------------------------------------------------

create table dbo.category_discounts
(
    id            int identity (1,1),
    category_id   int        not null foreign key references dbo.categories (id),
    promo_code_id varchar(6) not null foreign key references dbo.promo_codes (promo_code_id),
    update_date   datetime default getutcdate(),
    status        bit      default 1
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_discounts
(
    id                   int identity (1,1),
    product_variation_id varchar(6) not null foreign key references dbo.product_variations (variation_code),
    promo_code_id        varchar(6) not null foreign key references dbo.promo_codes (promo_code_id),
    update_date          datetime default getutcdate(),
    status               bit      default 1
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.sub_category_discounts
(
    id              int identity (1,1),
    sub_category_id int        not null foreign key references dbo.sub_categories (id),
    promo_code_id   varchar(6) not null foreign key references dbo.promo_codes (promo_code_id),
    update_date     datetime default getutcdate(),
    status          bit      default 1
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_promo_codes
(
    id            int identity (1,1),
    user_id       varchar(12) not null foreign key references dbo.user_accounts (user_id),
    promo_code_id varchar(6)  not null foreign key references dbo.promo_codes (promo_code_id),
    is_used       bit      default 1,
    update_date   datetime default getutcdate(),
    primary key (user_id, promo_code_id)
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.product_price_history
(
    id          int identity (1,1),
    product_id  varchar(6) not null foreign key references dbo.product_variations (variation_code),
    price       decimal(10, 2),
    update_date datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.favorites
(
    id                   int identity (1,1),
    user_id              varchar(12) not null foreign key references dbo.user_accounts (user_id),
    product_variation_id varchar(6)  not null foreign key references dbo.product_variations (variation_code),
    is_favorite          bit      default 1,
    update_date          datetime default getutcdate(),
    primary key (user_id, product_variation_id)
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.addresses
(
    id                    int identity (1,1),
    address_id            varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    first_name            varchar(50)  not null,
    last_name             varchar(50)  not null,
    street_address        nvarchar(50) not null,
    street_address_second nvarchar(50),
    country_id            varchar(6) foreign key references dbo.locations (location_id),
    location_id           varchar(6) foreign key references dbo.locations (location_id),
    city                  varchar(50)  not null,
    zip_code              varchar(5)   not null,
    phone_number          varchar(20)  not null,
    update_date           datetime                default getutcdate(),
    status                bit                     default 1
)

create unique index ux_address on dbo.addresses (street_address, city, zip_code, country_id);

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_addresses
(
    id          int identity (1,1),
    user_id     varchar(12) not null foreign key references dbo.user_accounts (user_id),
    address_id  varchar(12) not null foreign key references dbo.addresses (address_id),
    update_date datetime default getutcdate(),
    status      bit      default 1,
    primary key (user_id, address_id)
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.delivery_state
(
    id          int identity (1,1),
    state_id    int primary key,
    [name]      varchar(25),
    status      bit      default 1,
    update_date datetime default getutcdate()
)

insert into dbo.delivery_state(state_id, [name])
values (0, 'Pending'),
       (1, 'Shipped'),
       (2, 'Delivered'),
       (3, 'Cancelled')

------------------------------------------------------------------------------------------------------------------------

create table dbo.bank_cards
(
    id                  int identity (1,1),
    bank_card_id        varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    card_number         varchar(16) not null,
    card_holder_name    varchar(50) not null,
    card_holder_surname varchar(50) not null,
    expiration_date     varchar(5)  not null,
    cvv                 varchar(3)  not null,
    update_date         datetime               default getutcdate(),
    status              bit                    default 1
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.user_bank_cards
(
    id            int identity (1,1),
    user_id       varchar(12) not null foreign key references dbo.user_accounts (user_id),
    bank_carts_id varchar(6)  not null foreign key references dbo.bank_cards (bank_card_id),
    update_date   datetime default getutcdate(),
    primary key (user_id, bank_carts_id)
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.payment_statuses
(
    id          int identity (1,1),
    status_id   int primary key,
    name        varchar(30) not null,
    update_date datetime default getutcdate()
)

insert into dbo.payment_statuses(status_id, name)
values (0, 'Pending'),
       (1, 'Failed'),
       (2, 'Completed')

------------------------------------------------------------------------------------------------------------------------

create table dbo.carts
(
    id           int identity (1,1),
    cart_id      varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    user_id      varchar(12) not null foreign key references dbo.user_accounts (user_id),
    created_date datetime                default getutcdate(),
    update_date  datetime                default getutcdate()
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.cart_items
(
    id           int identity (1,1),
    cart_item_id varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    cart_id      varchar(12)    not null foreign key references dbo.carts (cart_id),
    product_id   varchar(6)     not null foreign key references dbo.product_variation_details (product_variation_id),
    size_id      int            not null foreign key references dbo.sizes (id),
    quantity     int            not null,
    price        decimal(10, 2) not null,
    is_selected  bit                     default 1,
    update_date  datetime                default getutcdate(),
    unique (cart_id, product_id, size_id)
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.orders
(
    id            int identity (1,1),
    order_id      varchar(12) primary key default lower(left(replace(newid(), '-', ''), 12)),
    user_id       varchar(12)    not null foreign key references dbo.user_accounts (user_id),
    promo_code_id varchar(6) foreign key references dbo.promo_codes (promo_code_id),
    total_amount  decimal(10, 2) not null,
    update_date   datetime                default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table order_item
(
    id              int identity (1,1),
    order_item_id   varchar(12) primary key                                                   default lower(left(replace(newid(), '-', ''), 12)),
    order_id        varchar(12) not null foreign key references dbo.orders (order_id),
    product_id      varchar(6)  not null foreign key references dbo.product_variation_details (product_variation_id),
    quantity        int         not null,
    price           decimal(10, 2),
    shipping_status int         not null foreign key references dbo.delivery_state (state_id) default 0,
    updated_date    datetime                                                                  default getutcdate()
);

------------------------------------------------------------------------------------------------------------------------

create table dbo.admin_actions
(
    id          int identity (1,1),
    user_id     varchar(12) not null foreign key references dbo.user_accounts (user_id),
    order_id    varchar(12) not null foreign key references dbo.orders (order_id),
    status_id   int foreign key references dbo.delivery_state (state_id),
    update_date datetime default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.shipping_details
(
    id              int identity (1,1) primary key,
    order_id        varchar(12) not null foreign key references dbo.orders (order_id),
    address_id      varchar(12) foreign key references dbo.addresses (address_id),
    shipping_status int         not null foreign key references dbo.delivery_state (state_id) default 0,
    update_date     datetime                                                                  default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.transactions
(
    id                int identity (1,1),
    transaction_id    varchar(12) primary key                                                     default lower(left(replace(newid(), '-', ''), 12)),
    order_id          varchar(12)    not null foreign key references dbo.orders (order_id),
    bank_card_id      varchar(6)     not null foreign key references dbo.bank_cards (bank_card_id),
    total_amount      decimal(10, 2) not null,
    payment_status_id int            not null foreign key references payment_statuses (status_id) default 2,
    update_date       datetime                                                                    default getutcdate()
)

------------------------------------------------------------------------------------------------------------------------

create table dbo.reviews
(
    id           int identity (1,1),
    review_id    varchar(6) primary key default lower(left(replace(newid(), '-', ''), 6)),
    user_id      varchar(12) not null foreign key references dbo.user_accounts (user_id),
    product_id   varchar(6)  not null foreign key references dbo.product_variation_details (product_variation_id),
    rating       int check (rating >= 1 and rating <= 5),
    comment      varchar(150),
    updated_date datetime               default getutcdate()
)