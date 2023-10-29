var modal = document.getElementById("myModal");

async function openHTML(  template="",where="modal", data=null, max='',){

  if(template.trim() != ""){
      return await new Promise((resolve,reject) =>{
          fetch( "templates/"+template)
          .then( stream => stream.text())
          .then( text => {
              const temp = document.createElement('div');
              temp.name = template
              temp.innerHTML = text;
              const err = temp.getElementsByTagName('template')[0] == undefined ? true : false
                if(err){
                    temp.innerHTML = '<title>ERROR 404!</title><template></template><script></script>'
                }  


                if(where == "modal"){
                    mainData[template.split('.')[0]] = new Object
                    mainData[template.split('.')[0]].func = new Object
                    mainData[template.split('.')[0]].data = data != null ? data : new Object
                    newModal(temp,max)
                }else{
                    document.querySelector('.main-content').innerHTML = temp.getElementsByTagName('template')[0].innerHTML
                    eval(temp.getElementsByTagName('script')[0].innerHTML);                                  
                }
                
          }); 
      }); 
  }
}

function closeModal(id='all'){

    function beforeClose(key){
        try{
            mainData[key].func.onClose()
        }catch{
            0
        }finally{
            if(!['data','coords'].includes(key)){
                delete mainData[key]
            }
        }
    }

    const mod_main = document.querySelector('#myModal')
    if(id=='all'){
        while(mod_main.querySelectorAll('.modal').length > 0){
            mod_main.querySelectorAll('.modal')[0].remove()    
            Object.entries(mainData).forEach(entry => {
                const [key, value] = entry;              
                beforeClose(key)
              });
        }
    }else{
        id = (id=='')? mod_main.querySelectorAll('.modal').length-1 : id
        const template = mod_main.querySelector('#modal-'+id).name.split('.')[0]
        delete mainData[mod_main.querySelector('#modal-'+id).name] 
        mod_main.querySelector('#modal-'+id).remove()

        const key = template.split('.')[0]
        beforeClose(key)
    }
    mod_main.style.display = (mod_main.querySelectorAll('.modal').length < 1) ? "none" : 'block'
}

function newModal(content, max=0){
    const mod_main = document.querySelector('#myModal')
    const index = mod_main.querySelectorAll('.modal-content').length        
    const offset_x = 0
    const offset_y = 15

    const backModal = document.createElement('div')
        backModal.classList = 'modal'
        backModal.id = 'modal-'+index
        backModal.name = content.name
        backModal.style.zIndex = 12+index
        backModal.style.display = 'block'

    const mod_card = document.createElement('div')
        mod_card.classList = 'modal-content'
        mod_card.style.position = 'absolute'
        mod_card.style.zIndex = 13+index
        mod_card.style.margin = '0 auto'
        mod_card.style.top =  50 + index*offset_y+'px'
        mod_card.style.left =  index*offset_x+'px'
        mod_card.style.right =  index*offset_x+'px'
        mod_card.style['max-width'] = max

    
    const mod_title = document.createElement('div')
    mod_title.className = 'modal-header'    
    const h2 = document.createElement('h2')
    h2.className = 'title-'+content.name.split('.')[0]
    h2.innerHTML = content.getElementsByTagName('title')[0].innerHTML
    mod_title.appendChild(h2)

    const span = document.createElement('span')
    span.classList = 'close'
    span.innerHTML = '&times;'
    span.addEventListener('click',()=>{
        closeModal(0)
    })
    mod_title.appendChild(span)
    mod_card.appendChild(mod_title)

    const mod_content = document.createElement('div')
    mod_content.classList = 'md-body'
    mod_content.innerHTML = content.getElementsByTagName('template')[0].innerHTML
    mod_card.appendChild(mod_content)    

    backModal.appendChild(mod_card)
    
    mod_main.appendChild(backModal)
    mod_main.style.display = "block"


    eval(content.getElementsByTagName('script')[0].innerHTML)

}

/* JQUERY  - Smooth Scroll*/

$(document).ready(function () {
    // Add smooth scrolling to all links
    $("a").on("click", function (event) {
      // Make sure this.hash has a value before overriding default behavior
      if (this.hash !== "") {
        // Prevent default anchor click behavior
        event.preventDefault();

        // Store hash
        var hash = this.hash;

        // Using jQuery's animate() method to add smooth page scroll
        // The optional number (800) specifies the number of milliseconds it takes to scroll to the specified area
        $("html, body").animate(
          {
            scrollTop: $(hash).offset().top,
          },
          800,
          function () {
            // Add hash (#) to URL when done scrolling (default click behavior)
            window.location.hash = hash;
          }
        );
      } // End if
    });
  });