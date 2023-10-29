var mbAttr = 'www.backhand.com.br';
var mapUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';    
var satUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

navigator.geolocation.getCurrentPosition((latlng)=>{
    mainData.data.lat = latlng.coords.latitude
    mainData.data.lng = latlng.coords.longitude
})

maplayer = L.tileLayer(mapUrl, {
    id: 'mapbox.streets',
    attribution: mbAttr
});

satlayer = L.tileLayer(satUrl, {
    id: 'mapbox.streets',
    attribution: mbAttr
});

function createMap(idMap, setview = [0,0], zoom=30){

    const layer = L.tileLayer(satUrl, {
        id: 'mapbox.streets',
        attribution: mbAttr
    });

    const myMap = L.map(idMap, {
        center: [30, 0],
        zoom: zoom,
        layers: [layer]
    }).setView(setview, zoom)

    myMap.removeLayer(satlayer);
    myMap.removeLayer(maplayer);
    myMap.addLayer(satlayer);

    if(setview[0] == 0){
        myMap.locate({setView: true, maxZoom: 16});
    }else{
        myMap.locate({setView: setview, maxZoom: zoom});
    }

    return myMap

}

function pinMap(latlng,map){
    var marker = new L.Marker(latlng);
    marker.addTo(map)
}

function geocoding(myMap,address){

    const url = 'https://geocode.maps.co/search?q='+address.trim()

    const myRequest = new Request(url,{
        method : "POST"
    });

    fetch(myRequest)
    .then(function (response){

        if (response.status === 200) { 
            response.text().then((txt)=>{
                try{
                    const json = JSON.parse(txt)
                    var newLatLng = new L.LatLng(json[4].lat,json[4].lon);
                    myMap.setView(newLatLng, 12);
                }catch{
                    alert('Favor verificar o nome da cidade digitado')
                }   
            })
        }
    })

}

function initGeolocation(){
    return navigator.geolocation.getCurrentPosition((a)=>{console.log(a)})
}

function disableMap(map){
    map.dragging.disable();
    map.touchZoom.disable();
    map.doubleClickZoom.disable();
    map.scrollWheelZoom.disable();
    map.boxZoom.disable();
    map.keyboard.disable();
//        map.style.cursor='pointer';        
}

