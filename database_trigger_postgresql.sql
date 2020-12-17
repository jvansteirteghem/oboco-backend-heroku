create or replace function readonly_trigger_function() returns trigger as $$
begin
  raise exception 'The "%" table is read only!', TG_TABLE_NAME;
  return null;
end;
$$ language 'plpgsql';

create trigger users_readonly_trigger before insert or update or delete on users for each statement execute procedure readonly_trigger_function();