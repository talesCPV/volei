/* GLOBAL DATA */ 
    const today = new Date
    var mainData = new Object
        mainData.data = new Object
            mainData.data.dashPos = 0
            mainData.data.dashDist = 100
            mainData.data.dashLim = 5
            mainData.data.activities = []
            mainData.data.memoryLength = 50
            mainData.data.lat = -23.0996385
            mainData.data.lng = -45.6866616
        mainData.func = new Object
        
    const maps = []
    
/* WINDOWS FUNCTIONS */

window.onscroll = function() {
    if (window.innerHeight + window.scrollY >= document.body.offsetHeight) {
//        loadActivity()
    }
}

/* FUNCTIONS */

function clearMemory(){
    if(mainData.data.activities.length > mainData.data.memoryLength){
        const div =  document.getElementById(mainData.data.activities[0])
        div.parentElement.removeChild(div);
        mainData.data.activities.splice(0,1)
    }
}

function showUserPic(){
    const back = backFunc({'filename':`../assets/users/${localStorage.getItem('idUser')}.jpg`},1)
    back.then((resp)=>{
        const imgExist = JSON.parse(resp)
        document.querySelector('#imgUser').src = imgExist ? `assets/users/${localStorage.getItem('idUser')}.jpg` : 'assets/default/user.jpeg'
    })
}

function breakImg(img,url='assets/default/user.jpeg'){
    img.addEventListener('error',()=>{
        img.src = url
    })   
}

function loadHash(data = {}){
    const hash = window.location.hash
    if(hash.length > 0){
        const OP = hash.substring(1,2)
        data.address = hash.substring(2,99)
    
        switch (OP){
            case 'P':                 
                openHTML('perfil.html','modal',data)
            break
            case 'G':
                openHTML('viewTrainning.html','modal',data)
            break
            case 'T':
                openHTML('viewTorn.html','modal',data)
            break            
        }
        removeHash()
    }
}

function nomeEtapa(NUM_JOG,FASE){

    const torn = mainData.viewTorn.data.torneio
    function fatoracao(N){
        let resto = 0
        let count = 0
        while(resto==0){
            resto = N%2
            N=N/2
            count++
        }
        return count-1
    }

    const fases = ['FINAL','SEMI FINAL','QUARTAS DE FINAL','OITAVAS DE FINAL']
    const index = fatoracao(Number(NUM_JOG))-Number(FASE)
    return index>fases.length ? 'Fase '+ FASE : fases[index]
}

function removeHash() { 
    history.pushState("", document.title, window.location.pathname + window.location.search);
}

function makeElement(kind,html='',cn='',id='',src='',target=''){
    const el = document.createElement(kind)
    id.trim()!=''?el.id=id:0
    cn.trim()!=''?el.className=cn:0
    html.trim()!=''?el.innerHTML=html:0
    target.trim()!=''?el.target=target:0

    if(src.trim()!=''){
        el.src=src
        breakImg(el)
    }
    return el
}


function loadActivity(keep=true){

    const divAtv = document.querySelector('.dashboard')
    divAtv.innerHTML = ''

    if(!keep){
        mainData.data.dashPos = 0
    }

    if(mainData.data.dashPos == '0'){
        try{
            const screen = document.querySelector('.dashboard')
            screen.innerHTML = ''
            mainData.data.activities = []    
        }catch{

        }
    }

    const params = new Object;
        params.id_user = localStorage.getItem('idUser')
        
    const myPromisse = queryDB(params,13);
    myPromisse.then((resolve)=>{
        mainData.data.dashPos += mainData.data.dashLim
        const json = JSON.parse(resolve)   
//console.log(json)

        for(let i=0; i<json.length; i++){            

            const back = backFunc({'filename':`../assets/treinos/${json[i].id_treino}.jpg`},1)
            back.then((resp)=>{
                imgExist = JSON.parse(resp)
                const path = imgExist ? `assets/treinos/${json[i].id_treino}.jpg` : 'assets/default/treino.jpeg'    

                const HTML = `
                        <div class="img-treino">
                            <img src=${path}>
                        </div>
                        <div class='dados-treino'>
                            <h2>${json[i].nome}</h2>
                            <h4>Dia ${json[i].data.showDate()} as ${json[i].data.showTime()}</h4>
                            <label>Local: ${json[i].local}</label>
                            <div>${json[i].obs}</div>
                        </div>
                `

            const atv = makeElement('div',HTML,'post-activity',`atv-${i}`) 
            
            atv.addEventListener('click',()=>{
                openHTML('viewAgenda.html','modal',json[i])
            })
            

            divAtv.appendChild(atv)




            }) 




  
            
  



        }
    })
}

function numJogosPC(N){
    let out = 0
    for(let i=0; i<N;i++){
        out += i
    }
    return out
}


/*  ABAS */

function pictab(e){
    const tab = e.id
    const content = document.querySelectorAll(".tab");
    for (let i = 0; i < content.length; i++) {
        const sel_tab = document.querySelector('#tab-'+content[i].id)

        if(content[i].id == tab.split('-')[1]){
            content[i].style.display = "block"
            sel_tab.style.background = "#16a083";
            sel_tab.style.color = "#FFF8DC";
        }else{
            content[i].style.display = "none"
            sel_tab.style.background = "#FFF8DC";
            sel_tab.style.color = "#16a083";
        }
    }
}
/* CALENDÀRIO */

function calendar(){
    const dw = ['D','S','T','Q','Q','S','S']
    const cal = document.createElement('div')
    cal.className = 'calendar'
    
    const td = new Date
    while(td.getDay()>0){
        td.change(-1)
    }                
    td.change(-21)

    for(let w=0; w<5; w++){
        const week = document.createElement('div')
        week.className = 'week'
        for(let d=0; d<7; d++){
            const day = document.createElement('div')
            day.className = 'day'
            day.id = td.getFormatDate()
            day.innerHTML = w==0?dw[d]:td.getDate()
            day.classList.add(w>0?'day-use':'day-name')
            w>0?td.change(1):0
            week.appendChild(day)
        }
        cal.appendChild(week)
    }
    return cal
}


/* VALIDATION */

function valInt(edt){
    edt.value = getNum(edt.value)
}

function valNoSpace(edt){
    edt.value = noSpace(edt.value)
}

function valForbid(edt,forbid){
    edt.value = forbidenStr(edt.value,forbid)
}

function forbidenStr(V,forbid){    
    let out = ''
    for(let i=0; i< V.length; i++){
        if(!forbid.includes(V[i])){
            out+=V[i]
        }
    }
    return out
}

function noSpace(V){
    let out = ''
    for(let i=0; i< V.length; i++){
        if(V[i]!=" "){
            out+=V[i]
        }
    }
    return out
}

function getNum(V, int=true){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    let out = int ? '0' : ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            out+=V[i]
        }
    }
    return int ? parseInt(out) : out
}

function getFone(V){
    let num = getNum(V,0)
    let out = '';
    for(i=0;i<num.length;i++){
        chr = num.substring(i,i+1);
        if(i == 0){
            out = '(' + out ;
        }
        if(i == 2){
            out = out + ')';
        }
        if(i == 6){
            out = out + '-';
        }
        if(i == 10){
            out = out.substring(0,5) +" "+out.substring(5,8)+out.substring(9,10)+"-"+out.substring(10,13)
        }		
        out = out + chr;			
    }
    return out
}


function validateEmail (email){
    return email.match(
      /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    );
};

function phone(param){ 
    param.value = getFone(param.value)
}

  
function validate(edt){

    if(validateEmail(edt.value)){
        edt.style.color = 'green'
        return true
    } else{
        edt.style.color = 'red'
        return false
    }

}

function checkMail(edt){
    const input = document.querySelector(edt)
    const out = validate(input)

    if(!out){
        alert('Digite um email válido!')
        input.focus()
    }

    return out

}


function goon(F){
    let out = true
    const fields = F.split(',')
    let focus

    for(let i=0; i<fields.length; i++){
        const txt = document.querySelector('#'+fields[i]).value.trim() == ''

        out = txt ? false : out
        txt ? focus = document.querySelector('#'+fields[i]) : 0        
    }

    if(!out){
        alert('Favor preencher todos os campos obrigatórios')
        focus.focus()
    }

    return out
}

function fillCombo(combo, params, cod, fields, value=''){

    combo = document.getElementById(combo)
    combo.innerHTML = ''
    const myPromisse = queryDB(params,cod);
    myPromisse.then((resolve)=>{
        const json = JSON.parse(resolve)        
        for(let i=0; i<json.length; i++){
            const opt = document.createElement('option')
            opt.value = json[i][fields[0]]
            opt.innerHTML = json[i][fields[1]].toUpperCase()
            opt.database = json[i]
            combo.appendChild(opt)
        }
        if(value != ''){
            combo.value = value
        }
    })
}

/* IMAGE */

function aspect_ratio(img,cvw=300, cvh=300){
    out = [0,0,cvw,cvh]
    w = img.width
    h = img.height
    
    if(w >= h){
        out[3] = cvh/(w/h)
        out[1] = (cvh - out[3]) / 2
    }else{
        out[2] = cvw/(h/w)
        out[0] = (cvw - out[2]) / 2
    }
    return out
}

function showFile(idFile,idCanvas){
    const inputFile = document.querySelector(idFile)
    if (inputFile.files && inputFile.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            loadImg(e.target.result,idCanvas)             
        }
        reader.readAsDataURL(inputFile.files[0]);
    }
}

function loadImg(filename, id='#cnvImg') {
    var ctx = document.querySelector(id); 
    try{
        const size = {w:ctx.width, h:ctx.height}
        if (ctx.getContext) {
            ctx = ctx.getContext('2d');
            ctx.clearRect(0, 0, size.w, size.h);
            var img = new Image();
            img.onload = function () {
                ar = aspect_ratio(img)
                ctx.drawImage(img, 0, 0,img.width,img.height,ar[0],ar[1],ar[2],ar[3]);
            };        
            img.src = filename;        
        }
    }catch{
        console.error('Imagem não existe!')
    }

}

function uploadImage(inputFile,path,filename){
    const up_data = new FormData();        
        up_data.append("up_file",  document.getElementById(inputFile).files[0]);
        up_data.append("path", path);
        up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    });

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

    return myPromisse
}