let notebookId;
let title;
let content;
let itemId;
let playerSource;

window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        $("body").fadeIn()
        notebookId = event.data.metadata[0].id
        title = event.data.metadata[0].title || ""
        content = event.data.metadata[0].content || ""
        itemId = event.data.metadata[0].item_id
        playerSource = event.data.source
        setContent(title, content)
        resizeTitle()
        // console.log(playerSource)
    } else if (event.data.type === 'close') {
        $("body").fadeOut()
    } else if (event.data.type === '') {

    }
});

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