## Create table to count conversions 

drop table mca_misc.tb_channel_1; 

create table mca_misc.tb_channel_1 as 

 

select  

a.org_party_id,  

a.created_date,  

a.viewdate,  

a.mql_status, 

a.converted, 

a.mql_count, 

a.audience_channel, 

a.audience_subchannel, 

min(a.viewdate) as from_time, 

max(a.created_date) as to_time, 

count(distinct a.session_id) as visits  

from mca_misc.tb_sfdc_web_at_all a  

where a.mql_status not like '%REJECTED%' 

 

group by  

a.org_party_id,  

a.audience_channel, 

 a.audience_subchannel, 

a.created_date, a.viewdate, 

a.mql_status,a.converted, 

a.mql_count 

 

 

## Count numbers of days between create and viewdate 

drop table mca_misc.tb_channel_a; 

create table mca_misc.tb_channel_a as 

select 

a.org_party_id,  

a.created_date,  

a.to_time, 

a.from_time, 

a.visits, 

a.converted, 

a.mql_count, 

a.audience_channel, 

a.audience_subchannel, 

datediff(a.created_date,a.from_time) as date_diff 

from   mca_misc.tb_channel_1 a 

group by  

a.org_party_id,  

a.audience_channel,  

a.audience_subchannel, 

a.created_date,  

a.to_time, 

a.from_time, 

a.visits, 

a.converted, 

a.mql_count 

 

## Change count of non_coversion to zero 

drop table mca_misc.tb_channel_b; 

create table mca_misc.tb_channel_b as 

select 

a.org_party_id,  

a.created_date,  

a.to_time, 

a.from_time, 

a.date_diff, 

a.visits, 

a.mql_count, 

a.visits-a.mql_count as non_conv, 

concat(a.audience_channel, ':', a.audience_subchannel) as channels 

 

 

from mca_misc.tb_channel_a a 

group by  

a.org_party_id, 

 a.audience_channel, 

 a.audience_subchannel, 

a.created_date,  

a.to_time, 

a.from_time, 

a.mql_count, 

a.date_diff, 

a.visits 

 

 

##Create Channel Table 

drop table mca_misc.tb_channel_c; 

create table mca_misc.tb_channel_c as 

select  

a.org_party_id,  

 a.created_date,  

a.from_time, 

a.to_time, 

a.date_diff, 

a.mql_count,  

a.non_conv, 

a.visits, 

a.mql_count/a.visits as conv_rate, 

a.channels 

from mca_misc.tb_channel_b a 

 

 

##Create Path variable and order by viewdate 

 

 

###Trying to set to and from and path 

 

 

##Path order by from date 

drop table mca_misc.tb_channel_path_a; 

create table mca_misc.tb_channel_path_a as 

select  

a.org_party_id, 

count(channels) AS path_num, 

concat_ws(">", collect_list(a.channels)) as path from  
      (  
        select * from mca_misc.tb_channel_c order by from_time dec 
       ) a 

 

group by  

a.org_party_id 

 

##Add journey to KPIS 

drop table mca_misc.tb_channel_path; 

create table mca_misc.tb_channel_path as 

 

select 

a.org_party_id, 

a.from_time, 

a.to_time, 

sum(a.mql_count) as conversion,  

sum(a.non_conv) as null, 

sum(visits) as visits, 

b.path 

 

from mca_misc.tb_channel_c a left join mca_misc.tb_channel_path_a b on (a.org_party_id = b.org_party_id) 

 

 

group by 

a.org_party_id, 

a.from_time, 

a.to_time, 

b.path 

 

## Create Conversion Rate 

drop table mca_misc.tb_channel_path_b; 

create table mca_misc.tb_channel_path_b as 

select 

a.org_party_id, 

a.conversion, 

a.null, 

a.visits, 

a.from_time, 

a.to_time, 

a.conversion/a.visits as conv_rate, 

a.path 

 

from  mca_misc.tb_channel_path a 

 

group by 

a.org_party_id, 

a.conversion, 

a.from_time, 

a.to_time, 

a.null, 

a.visits, 

a.path 
