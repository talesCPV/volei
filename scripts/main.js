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
        document.querySelector('#imgUser').src = imgExist ? `assets/users/${localStorage.getItem('idUser')}.jpg` : 'assets/user.jpeg'
    })
}

function fillPerfil(usr){

    const params = new Object;
        params.id =  usr

    const myPromisse = queryDB(params,27);
    myPromisse.then((resolve)=>{
        const json = JSON.parse(resolve)  
        const img = document.querySelector('#perfil-img') 

        img.src = `assets/users/${json[0].id}.jpg`
        breakImg(img)

        document.querySelector('#imgUser').src = img.src
        breakImg(document.querySelector('#imgUser'))
        document.querySelector('.perfil-seguindo').innerText = 'Seguindo '+json[0].SEGUINDO.padStart(2,0)
        document.querySelector('.perfil-seguidores').innerText = 'Seguidores '+json[0].SEGUIDORES.padStart(2,0)
        document.querySelector('.perfil-atividades').innerText = 'Atividades '+json[0].ATIVIDADES.padStart(2,0)
        document.querySelector('.perfil-nome').innerText = json[0].nome
        document.querySelector('.perfil-nivel').innerText = json[0].nivel
        document.querySelector('.rating-bg').value = json[0].nivel

        try{
            json[0].ALERTA_QTD = parseInt(json[0].ALERTA_QTD)
            json[0].ALERTA_ATV = json[0].ALERTA_ATV.split(',')
            json[0].ALERTA_NOME = json[0].ALERTA_NOME.split(',')
        }catch{
            json[0].ALERTA_QTD = ''
            json[0].ALERTA_ATV = []
            json[0].ALERTA_NOME = []
        }

        try{
            json[0].ALERTA_TORN_QTD = parseInt(json[0].ALERTA_TORN_QTD)
            json[0].ALERTA_TORN_ID = json[0].ALERTA_TORN_ID.split(',')
        }catch{
            json[0].ALERTA_TORN_QTD = ''
            json[0].ALERTA_TORN_ID = ''
        }

        mainData.data.perfil = json[0]
        document.querySelector('#alert').innerText = json[0].ALERTA_QTD
        document.querySelector('#alert-torn').innerText = json[0].ALERTA_TORN_QTD
    })
}

function breakImg(img,url='assets/user.jpeg'){
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

function makeActivity(ATV,classScreen,showUser=true){
    
    const screen =  document.querySelector('.'+classScreen)
    const mapDiv = 'map-'+classScreen
    const i = maps.length
    const owner = localStorage.getItem('idUser') == ATV.id_usuario


    let timeA = {nome:'',id:[]}
    let timeB = {nome:'',id:[]}
    const nome_atl = ATV.ATLETAS.split(',')
    const id_atl = ATV.ID_ATLETAS.split(',')
    const times = ATV.LADO.split(',')

    for(let j=0; j<nome_atl.length; j++){
        if(times[j].trim()=='A'){
            timeA.nome += (timeA.nome.length>0 ?',':'') +  nome_atl[j].trim()
            timeA.id.push(parseInt(id_atl[j]))
        }else{
            timeB.nome += (timeB.nome.length>0 ?',':'') +  nome_atl[j].trim()
            timeB.id.push(parseInt(id_atl[j]))
        }           
    }  


    const mainDiv = makeElement('div','','post-activity',`atv-${i}`)

    const head = makeElement('div','','head-activity')
    if(showUser){
        
        const img = makeElement('img','','imgUser head-activity-img','',`assets/users/${ATV.id_usuario}.jpg`)    
        img.addEventListener('click',()=>{
            window.location.hash = 'P'+ATV.id_usuario.padStart(10,0)
            loadHash()
        })
        head.appendChild(img)

        const div1 = makeElement('div')                        
        const headAtl = makeElement('p',ATV.NOME_ATLETA,'head-activity-atleta')        
        div1.appendChild(headAtl)

        const headDat = makeElement('p',`${ATV.dia.showDate()} as ${ATV.dia.showTime()}`,'head-activity-data')        
        div1.appendChild(headDat)
        head.appendChild(div1)
        mainDiv.appendChild(head)
    }else{
        head.appendChild(makeElement('p',`${ATV.dia.showDate()} as ${ATV.dia.showTime()}`,'head-activity-data'))
    }
    
    const h2Nome = makeElement('h2',`${ATV.ranking=="1"?'<i class="fas fa-trophy"></i> ':''}  ${ATV.nome}` ,'','nome')
    mainDiv.appendChild(h2Nome)

    !showUser ? mainDiv.appendChild(head) : 0

    if(timeB.nome.trim()!=''){

        const p1_score = parseInt(ATV.SETS_P1)
        const p2_score = parseInt(ATV.SETS_P2)

        if(p1_score+p2_score==0){
            const h4Placar = makeElement('h4',`<span class="mdi mdi-tennis"></span> ${timeA.nome} & ${timeB.nome}`,'','placar')    
            mainDiv.appendChild(h4Placar)        
        }else{
            const h4Placar = makeElement('h4',`${timeA.nome}  ${p1_score} x ${p2_score}  ${timeB.nome}`,'','placar')    
            mainDiv.appendChild(h4Placar)        
        }

    }

    const panel = makeElement('div','','panel')
    const leftPanel = makeElement('div','','left-panel')
    const map = makeElement('div','','map-view')
    leftPanel.appendChild(map)
    const mapAct = makeElement('div','','map-activity',mapDiv+i)
    leftPanel.appendChild(mapAct)
    const h6Map = makeElement('h6',ATV.QUADRA,'map-label')
    leftPanel.appendChild(h6Map)
    panel.appendChild(leftPanel)

    const rigthPanel = makeElement('div','','right-panel')
    const pSport = makeElement('p',`${ATV.SPORT} (${ATV.EVENTO})`,'','sport')
    rigthPanel.appendChild(pSport)
    if(owner){
        const div2 = makeElement('div','',`only-login social-icon ${localStorage.getItem('idUser') == null ? 'hide-menu' : ''}`)
    
        const link = encodeURI('https://www.backhand.com.br/#G'+ATV.id.padStart(10,0));
        const msg = encodeURIComponent('Hey, olhe meu treino no backhand');
        
        const facebook = makeElement('a','<i class="fab fa-facebook">','facebook','','','blank')
        facebook.href = `https://www.facebook.com/share.php?u=${link}`;
        div2.appendChild(facebook)
        const twitter = makeElement('a','<i class="fab fa-twitter"></i>','twitter','','','blank')
        twitter.href = `http://twitter.com/share?&url=${link}&text=${msg}&hashtags=javascript,programming`;
        div2.appendChild(twitter)
        const linkedin = makeElement('a','<i class="fab fa-linkedin"></i>','linkedin','','','blank')
        linkedin.href = `https://www.linkedin.com/sharing/share-offsite/?url=${link}`;
        div2.appendChild(linkedin)
        const reddit = makeElement('a','<i class="fab fa-reddit"></i>','reddit','','','blank')
        reddit.href = `http://www.reddit.com/submit?url=${link}&title=${msg}`;
        div2.appendChild(reddit)
        const whatsapp = makeElement('a','<i class="fab fa-whatsapp"></i>','whatsapp','','','blank')
        whatsapp.href = `https://api.whatsapp.com/send?text=${msg}: ${link}`;
        div2.appendChild(whatsapp)
        const telegram = makeElement('a','<i class="fab fa-telegram"></i>','telegram','','','blank')
        telegram.href = `https://telegram.me/share/url?url=${link}&text=${msg}`;
        div2.appendChild(telegram)
        rigthPanel.appendChild(div2)
    }

    panel.appendChild(rigthPanel)
    mainDiv.appendChild(panel)

    const socialPanel = makeElement('div','','panel-social')
    const numKudos = makeElement('div',`${ATV.KUDOS.padStart(2,0)} kudos`,'social-kudos')
    socialPanel.appendChild(numKudos)
    const div3 = makeElement('div')
    div3.style = 'display:flex; gap:5px;'
    const btnKudos = makeElement('button','<i class="fas fa-thumbs-up"></i>','btn-backhand btn-social')
    btnKudos.addEventListener('click',()=>{
        if(localStorage.getItem('idUser') != null){             
            const params = new Object;
                params.hash =  localStorage.getItem('hash')
                params.id_atividade = ATV.id
            const myPromisse = queryDB(params,18)
            myPromisse.then((resolve)=>{                       
                numKudos.innerHTML = JSON.parse(resolve)[0].KUDOS.padStart(2,0)+ ' kudos'                                     
            })
        }
    })
    div3.appendChild(btnKudos)
    const btnScrap = makeElement('button','<i class="fas fa-comments"></i>','btn-backhand btn-social')
    btnScrap.addEventListener('click',()=>{
        openHTML('message.html','modal',ATV)
    })
    div3.appendChild(btnScrap)
    socialPanel.appendChild(div3)
    mainDiv.appendChild(socialPanel)
    mainDiv.database = ATV

    screen.appendChild(mainDiv)        
    mainData.data.activities.push(`atv-${i}`)

    clearMemory()

    maps.push(createMap(mapDiv+i,[ATV.lat, ATV.lng],30))
    pinMap([ATV.lat, ATV.lng],maps[maps.length-1])
    maps[maps.length-1].locate({setView: false, maxZoom: 30})
    disableMap(maps[maps.length-1])
    maps[maps.length-1].on('click',()=>{
        mainData.data.formID = `atv-${i}`
        window.location.hash = 'G'+ATV.id.padStart(10,0)
        loadHash()
    })

}

function loadActivity(keep=true){

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
        params.lat =  mainData.data.lat
        params.lng =  mainData.data.lng
        params.maxDistance = mainData.data.dashDist
        params.start = mainData.data.dashPos
        params.limit = mainData.data.dashLim
        
    const myPromisse = queryDB(params,9);
    myPromisse.then((resolve)=>{
        mainData.data.dashPos += mainData.data.dashLim
        const json = JSON.parse(resolve)   
//console.log(json)
        for(let i=0; i<json.length; i++){            
            makeActivity(json[i],'dashboard')          
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
            w>0?day.classList.add('day-use'):0
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