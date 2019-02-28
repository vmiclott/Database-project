select location.streetname, max(earth_distance(ll_to_earth(location2.latitude,location2.longitude),ll_to_earth(location.latitude,location.longitude))) as d from location inner join location as location2 using(streetname)
group by streetname
order by d desc limit 1
