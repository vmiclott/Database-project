-- Personid was added to the query because it's necessary to define a photo

select distinct article.title as articletitle, publishtime as articlepublished, filename as photofilename, photo.personid
from article_photo inner join photo using (personid,filename) inner join article using(articleid)
where date<publishtime and date>publishtime-interval '30 day'
order by articlepublished, photofilename