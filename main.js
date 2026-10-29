
const downloadTable = document.getElementById('downloadTable')
const downloadTableBody = document.getElementById('downloadTableBody')
// Table Headers
// Name, Description Download


// Table objects
const tableObject = [
    {
        Name: "Easy Does It! Example Project",
        Description: "This is the example project used within our methods paper.",
        Download: "ZippedFiles/EasyDoesIt.zip"
    },

    {
        Name: "Blank Template",
        Description: "A standard blank template you can use to get started with any interactive search project.",
        Download: "ZippedFiles/BlankTemplate.zip"
    },

    {
        Name: "R Helper Functions",
        Description: "This is an R script containing the helper/processing functions that can be used to simplify processing the data produced by the IST.",
        Download: "ZippedFiles/RProcessingFunctions.zip"
    },

    {
        Name: "Latest IST Build",
        Description: "This is the latest Interactive Search Toolbox build file. If you do not wish to use a CDN in your project you can instead download this file and include it as a script tag within the head tags of your index file.",
        Download: "https://cdn.jsdelivr.net/gh/InteractiveSearchToolbox/IST@main/build/IST.min.js"
    }
]



for(let i = 0; i < tableObject.length; i++){
    const rowData = tableObject[i]
    const arow = document.createElement('tr')
    const name = document.createElement('td')
    
    const description = document.createElement('td')
    const descriptionText = document.createElement('div')

    const download = document.createElement('td')
    const downloadLink = document.createElement('a')
    const downloadButton = document.createElement('button')
    
    downloadLink.setAttribute('href', rowData.Download)
    downloadLink.setAttribute('download', rowData.Name)
    
    
    
    name.innerText = rowData.Name
    descriptionText.innerText = rowData.Description
    descriptionText.setAttribute('class', 'descriptionTextCell')
    description.setAttribute('class', 'descriptionCell')
    description.append(descriptionText)
    downloadButton.innerText = 'Download!'
    downloadButton.title = rowData.Name;

    downloadButton.addEventListener('click', function(){
        downloadLink.click()            
    })

    download.append(downloadButton)
    
    //download.innerText = rowData.Download
    
    arow.append(name, description, download)
    downloadTableBody.appendChild(arow)
}