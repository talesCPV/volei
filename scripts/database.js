/*  DATABASE  */

function queryDB(params,cod){
    const data = new URLSearchParams();        
        data.append("cod", cod);
        data.append("params", JSON.stringify(params));
        data.append("storage", localStorage.getItem("storage"));

    const myRequest = new Request("backend/query_db.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            }if (response.status === 500 && localStorage.getItem('idUser') != null) { 
                setTimeout(() => {
                    switch (cod){
                        case 9:
                            mainData.data.dashPos = 0
                            mainData.data.dashDist = 100
                            mainData.data.dashLim = 5
                            mainData.data.activities = []
                            mainData.data.memoryLength = 50                            
                            loadActivity()
                        break
                    }

                }, 3000)
            }else{ 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });      
}

function backFunc(params,cod){
    const data = new URLSearchParams();        
        data.append("cod", cod);
        data.append("params", JSON.stringify(params));        

    const myRequest = new Request("backend/functions.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    });      
}

function queryJson(json,cod,clause=''){


    const out = JSON.stringify(json)

    const data = new URLSearchParams();        
        data.append("cod",cod)
        data.append("json", out)
        data.append("clause",clause)
        data.append("owner",localStorage.getItem('hash'))

    const myRequest = new Request("backend/query_json.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

}