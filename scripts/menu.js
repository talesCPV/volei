
/* close mobile menu when choose */

for(let i=0; i<document.querySelectorAll('.menu-items li').length; i++){
    document.querySelectorAll('.menu-items li')[i].addEventListener('click',()=>{
        document.querySelector('#ckbHamb').checked = false
    })
}
