async function cityUF(UF){

    return new Promise((resolve,reject) =>{
        fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${UF}/municipios`)
        .then(function (response){
            if (response.status === 200) {
                resolve(response.text());
            }else{
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            }
        });
    });
}

async function cityCod(cod){
    return new Promise((resolve,reject) =>{
        fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/municipios/${cod}`)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            }else{ 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });
}

async function regCod(cod){
    return new Promise((resolve,reject) =>{
        fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/microrregioes/${cod}/distritos`)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            }else{ 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });
}