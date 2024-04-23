let notebookId;
let title;
let content;
let itemId;
let playerSource;

window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        $("body").fadeIn()
        notebookId = event.data.notebookId
        playerSource = event.data.source
        resizeTitle()
        // console.log(playerSource)
    } else if (event.data.type === 'close') {
        $("body").fadeOut()
    } else if (event.data.type === 'pages') {
        setPages(event.data.pages)
    }
});

function setPages(pages) {
    let page_list = ""
    pages.forEach(page => {
        page_list += `<a onclick="setContent('${page.title}', '${page.content}');return false;">${page.title}</a>`
    });

    $("#notebook_pages").html(page_list)
}

function setContent(title, content) {
    $('#notebookTitle').val(title)
    $('#notebookContent').val(content)
}

function resizeTitle() {        
    fitty('#notebookTitle', {
        maxSize: 80
    });
}

// Button Management
function saveChanges() {
    $('#notebookTitle').attr("readonly", true)
    $('#notebookContent').attr("readonly", true)
    $('#saveChanges').attr("readonly", true).fadeOut()
    $('#startEditing').attr("readonly", false)
    $('#addPage').attr("readonly", false)
    $('.button-group').fadeIn()

    title = $('#notebookTitle').val()
    content = $('#notebookContent').val()
    console.log(title, content, notebookId, playerSource)

    $.post(`https://${GetParentResourceName()}/saveNote`, 
        JSON.stringify({
            title: title, 
            content: content,
            notebookId: notebookId,
            itemId: itemId,
            playerSource: playerSource
        }))
}

function startEditing() {
    $('#notebookTitle').attr("readonly", false)
    $('#notebookContent').attr("readonly", false)
    $('#startEditing').attr("readonly", true)
    $('#addPage').attr("readonly", true)
    $('.button-group').fadeOut()
    $('#saveChanges').attr("readonly", false).fadeIn()
}

function addPage() {    
    $.post(`https://${GetParentResourceName()}/AddPage`, 
        JSON.stringify({
            notebookId: notebookId
        }))
}

function closeNote() {
    $("body").fadeOut()
    $.post(`https://${GetParentResourceName()}/closeNotebook`, JSON.stringify({}))
}

function getContent() {    
    // $.post(`https://${GetParentResourceName()}/getNoteContent`, JSON.stringify({}))
    //     .success(() => { console.log("test")})
}