/*  STRING  */
String.prototype.getHash = function(S){
    let weigth = 0
    let hash = ''
    let str = this.valueOf()

    function getRange(N){ // keeps caracters under ASCII 33 & 126
        while (N > 126 || N < 33){
            N -= 126
            N < 33 ? N += 33 : N
            N == 127 ? N++ : 0
        }
        return N
    }

    for (i = 0; i < str.length; i++) {
        weigth += str.charCodeAt(i) * 5
    }

    while(str.length < S){
        str += String.fromCharCode(str.length + 33)
    }

    for (i = 0; i < str.length; i++) {
        chr = getRange(weigth * str.charCodeAt(i))
        chr = chr===92 ? 168 : chr;
        chr = chr===34 ? 173 : chr;
        hash += String.fromCharCode(chr)  
    }

    return hash;
}

String.prototype.showDate = function(){
    const str = this.valueOf()
    return str.substr(8,2).padStart(2,0)+'/'+str.substr(5,2).padStart(2,0)+'/'+str.substr(0,4)
}

String.prototype.showTime = function(){
    const str = this.valueOf()
    return str.substr(11,5)
}

/* TABLE */
HTMLTableElement.prototype.plot = function(obj, fields,type='',file=false, mark=false , green=false){

    fields = fields.split(',')
    type = type=='' ? '' : type.split(',')
    const tr = document.createElement('tr')
    if(file && obj.path != null){
        tr.classList = 'path'
    }
    for(let i=0; i<fields.length; i++){
        const td = document.createElement('td')
        const arr = fields[i].split('|')
        if(arr.length > 1){
            td.classList = arr[1]
        }
        let html, op
    
        if(type.length > 0 && i<type.length){
            switch (type[i].substring(0,3)) {
                case 'int':
                  html = parseInt(obj[arr[0]])
                  break;
                case 'per':
                    html = parseFloat(obj[arr[0]]).toFixed(2) + '%'
                    break;                  
                case 'sta':
                    
                    html = `
                    <div class="rating-line">
                        <div class="rating">
                            <progress id="rtn-saque" class="rating-bg" value="${arr[0]}" max="5"></progress>
                            <svg id="svg-saque"><use xlink:href="#fivestars"/></svg>
                        </div>    
                    </div>
                    `
/*                    
                    for(let j=0; j<parseInt(arr[0]); j++){
                        alert(j)
                        html += '<span class="fa fa-star checked"></span>'
                    }
*/                    
                    break;
                case 'flo':
                    html = obj[arr[0]] != null ? parseFloat(obj[arr[0]]).toFixed(2) : ''
                    break;
                case 'Upp':
                    html = obj[arr[0]] != null ? obj[arr[0]].toUpperCase().trim() : ''
                    break
                case 'str':
                    html = obj[arr[0]] != null ? obj[arr[0]].trim() : ''
                  break;
                case 'dat':
                    if(obj[arr[0]] == null){
                        html = 'A Marcar'
                    }else{
                        html = obj[arr[0]] != null ? obj[arr[0]].substring(8,10)+'/'+ obj[arr[0]].substring(5,7)+'/'+obj[arr[0]].substring(0,4) : ''
                    }
                    break                 
                case 'Low':
                    html = obj[arr[0]] != null ? obj[arr[0]].toLowerCase().trim() : ''
                    break;
                case 'R$.':
                    if(parseFloat(obj[arr[0]]).toFixed(2) >=0 ){
                        html = obj[arr[0]] != null ? viewMoneyBR(parseFloat(obj[arr[0]]).toFixed(2)) : ''   //'R$'+ parseFloat(obj[arr[0]]).toFixed(2)
                        green = true
                    }else{
                        html = obj[arr[0]] != null ? `(${viewMoneyBR(parseFloat(obj[arr[0]]).toFixed(2))})` : ''   //'R$'+ parseFloat(obj[arr[0]]).toFixed(2)
                        green = false
                    }
                    break;             
                case 'cha':
                    op = type[i].split(' ')
                    html = ''
                    for(let j=1; j<op.length; j++){
                        if((obj[arr[0]] == op[j].split('=')[0])||(j==op.length-1 && html=='')||obj[arr[0]] == null ){
                            html = op[j].split('=')[1] == '**' ? obj[arr[0]] : op[j].split('=')[1]
                        }
                    }
                    break;
                case 'fun':
                    op = type[i].split(' ')                    
                    html = eval(`${op[1]}(obj[arr[0]])`)
                    break;
                case 'cal':
                    op = type[i].split(' ')                   
                    html = eval(op[1])
                    break;
                case 'con':
                    op =   arr[0].split('#')
                    const campo = op[0].split(' ')
                    html = ''
                    for(let j=0; j< campo.length; j++){
                        html +=  obj[campo[j]] 
                        html += j<campo.length-1 ? op[1] : ''
                    }
                    break; 
                case 'ckb':                            
                    html = `<input type="checkbox" id="tblCkb_${this.rows.length-1}" class="tbl-ckb" ${parseInt(obj[arr[0]])? '' : 'checked'}>`
                    break;  
                case 'let':                            
                    html = arr[0]
                    break;
                case 'cut':
                    const pos = parseInt(type[i].substring(3,6))
                    html = obj[arr[0]] != null ? obj[arr[0]].trim().substring(0,pos) : ''
                    break;                                       

                default:
                  html = obj[arr[0]] != null ? obj[arr[0]] :''
            }            
        }else{
            html = obj[fields[i].split('|')[0]]
        }
        td.innerHTML = html
        tr.appendChild(td)
    }
    tr.data = obj
    if(mark){
        tr.style.background = green ? 'rgb(99, 201, 99)' : 'rgb(201, 99, 99)'
        tr.style.color = green ? 'rgb(0,0,0)' : 'rgb(255,255,255)'
    }
    this.appendChild(tr)
}

HTMLTableElement.prototype.head = function(hd,clear=true){
    this.innerHTML = clear ? '' : this.innerHTML
    hd = hd.split(',')
    const tr = document.createElement('tr')
    for(let i=0; i<hd.length; i++){
        const th = document.createElement('th')
        const arr = hd[i].split('|')
        if(arr.length > 1){
            th.classList = arr[1]
        }
        if(arr[0] == 'ckb-all'){
            const all = document.createElement('input')
            all.type = 'checkbox'
            all.addEventListener('click',(e)=>{
                var nodes = Array.prototype.slice.call(e.target.parentNode.parentNode.children);
                const index = nodes.indexOf(e.target.parentNode)

                for(let i=1; i<this.rows.length; i++){
                    try{
                        this.rows[i].cells[index].children[index].checked = all.checked
                    }catch{
                        console.error('Erro controlado, vai ficar assim mesmo!');
                    }
                }
            })
            th.appendChild(all)

        }else{
            th.innerHTML = arr[0]
        }
        tr.appendChild(th)
    }
    this.appendChild(tr)
}

/* DATE */
Date.prototype.change = function(N=1){
    this.setDate(this.getDate()+N)
 }
 
Date.prototype.addMin = function(N=1){
    this.setTime(this.getTime() + N*60000)
}

Date.prototype.iniMonth = function(){
    const day = this.getDate() -1
    this.change(-day)
    const out = this.getFormatDate()
    this.change (day)
    return out
}

Date.prototype.finMonth = function(){
    const day = this.getDate() -1
    this.change(30-day)
    const out = this.getFormatDate()
    this.change (-30+day)
    return out
}

Date.prototype.getFormatDate = function(N=''){
    if(N==''){
        return (`${this.getFullYear()}-${(this.getMonth()+1).toString().padStart(2,'0')}-${this.getDate().toString().padStart(2,'0')}`)
    }else{
        this.change(N)
        const out = `${this.getFullYear()}-${(this.getMonth()+1).toString().padStart(2,'0')}-${this.getDate().toString().padStart(2,'0')}`
        this.change(-N)
        return out
    }
}

Date.prototype.getFormatBR = function(){
    return (`${this.getDate().toString().padStart(2,'0')}/${(this.getMonth()+1).toString().padStart(2,'0')}/${this.getFullYear()}`)
}

Date.prototype.getFullHour = function(){
    return (`${this.getHours().toString().padStart(2,'0')}:${this.getMinutes().toString().padStart(2,'0')}:${this.getSeconds().toString().padStart(2,'0')}`)
}

Date.prototype.getFullTime = function(){
    return (`${this.getHours().toString().padStart(2,'0')}:${this.getMinutes().toString().padStart(2,'0')}`)
}

Date.prototype.getFullDate = function(){
    return `${this.getFormatBR()} ${this.getFullHour()}`
}

Date.prototype.getFullDateTime = function(){
    return `${this.getFormatDate()}T${this.getFullHour()}-03:00`
}

Date.prototype.getWeekDay = function(){
    const dia = ['Dom','Seg','Ter','Qua','Qui','Sex','Sab']
    return dia[this.getDay()]
}

Date.prototype.getCod = function(){
    return this.getFullYear().toString().substring(2,4) + (this.getMonth()+1).toString().padStart(2,'0') + this.getDate().toString().padStart(2,'0')
}