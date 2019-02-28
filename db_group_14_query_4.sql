select email,case when articlephotos is null then '0.00%' when articlephotos is not null and cast((cast(articlephotos as float)/ cast(total as float)) * 100 as decimal)<10 then concat('0',round(cast((cast(articlephotos as float)/ cast(total as float)) * 100 as decimal),2),'%') else concat(round(cast((cast(articlephotos as float)/ cast(total as float)) * 100 as decimal),2),'%') end as perc
from
((select count(distinct (personid,filename)) as total, personid from photo group by personid) as a
full join
(select count(distinct (photo.personid,filename)) as articlephotos, photo.personid from photo inner join article_photo using(filename,personid) group by photo.personid) as b
using(personid)) as c inner join person using(personid)
order by perc desc