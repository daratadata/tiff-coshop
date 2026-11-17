-- À exécuter APRÈS supabase.sql
alter table orders add column fee int default 0;
create table settings(id int primary key default 1,v jsonb);
alter table settings enable row level security;
create policy "tarifs publics" on settings for select using(true);
create policy "tarifs admin" on settings for all using(is_admin()) with check(is_admin());
insert into settings values(1,'{"detail":1000,"gros":800,"gros_min":10,"demi":20000,"carton":40000,"carton2":35000}');
insert into zones(name,fee) values('Abidjan - Cocody',1000),('Abidjan - Yopougon',1500);
create function dec_stock() returns trigger language plpgsql security definer as $$
declare i jsonb;begin for i in select * from jsonb_array_elements(new.items) loop update products set stock=stock-(i->>'qty')::int where id=i->>'id';end loop;return new;end$$;
create trigger on_order after insert on orders for each row execute function dec_stock();
