
const downloadTable = document.getElementById('downloadTable')
const downloadTableBody = document.getElementById('downloadTableBody')
// Table Headers
// Name, Description Download


// Table objects
const tableObject = [
    {
        Name: "Easy Does It! Example Project",
        Description: "This is the example project used within our methods paper.",
        Download: "ZippedFiles/EasyDoesIt.zip",
        DownloadName: "EasyDoesIt.zip",
        downloadType: 'zip'
    },

    {
        Name: "Blank Template",
        Description: "A standard blank template you can use to get started with any interactive search project.",
        Download: "ZippedFiles/BlankTemplate.zip",
        DownloadName: "BlankTemplate.zip",
        downloadType: 'zip'
    },

    {
        Name: "R Helper Functions",
        Description: "This is an R script containing the helper/processing functions that can be used to simplify processing the data produced by the IST.",
        Download: "Files/RProcessingFunctions/Processing Functions.R",
        DownloadName: "Processing Functions.R",
        downloadType: 'R'
    },

    {
        Name: "Latest IST Build",
        Description: "This is the latest Interactive Search Toolbox build file. If you do not wish to use a CDN in your project you can instead download this file and include it as a script tag within the head tags of your index file.",
        Download: "https://cdn.jsdelivr.net/gh/InteractiveSearchToolbox/IST@latest/build/IST.min.js",
        DownloadName: "IST.min.js",
        downloadType: 'cdn'
    },
    {
        Name: "Cube Models",
        Description: "GLB files for the cube stimuli used in our <a href = 'https://doi.org/10.3758/s13414-025-03083-w' target = '_blank'>'Easy First' Experiment</a>.",
        Download: "ZippedFiles/CubeGLBModels.zip",
        DownloadName: "CubeGLBModels.zip",
        downloadType: 'zip'
    },

    {
        Name: "Coin Models",
        Description: "GLB files for coin stimuli used in our <a href = 'https://doi.org/10.1177/17470218261436006' target = '_blank'>'What Drives Object Selection?' Experiment</a>.",
        Download: "ZippedFiles/CoinGLBModels.zip",
        DownloadName: "CoinGLBModels.zip",
        downloadType: 'zip'
    },

    {
        Name: "Large Real Cubes (3D Printer Files - .stl)",
        Description: "This contains all the files to 3D print and replicate the stimuli used within our <a href = 'https://doi.org/10.3758/s13414-026-03296-7' target = '_blank'>Real-world motion tracked interactive search experiment</a>.",
        Download: "ZippedFiles/Large3DCubeSTLs.zip",
        DownloadName: "Large3DCubeSTLs.zip",
        downloadType: 'zip'
    },

    {
        Name: "Small Real Cubes (3D Printer Files - .stl)",
        Description: "This contains all the files to 3D print and replicate the stimuli used within our <a href = 'https://doi.org/10.1080/13506285.2026.2616307' target = '_blank'>Effects of effort upon real-world interactive search experiment</a>.",
        Download: "ZippedFiles/Small3DCubesSTL.zip",
        DownloadName: "Small3DCubesSTL.zip",
        downloadType: 'zip'
    },

    {
        Name: "T and L Stimuli Images",
        Description: "PNG files for the T and L stimuli shapes we used in our <a href = 'https://doi.org/10.3758/s13414-026-03296-7' target = '_blank'>Mind wandering and target prevalence study</a> and many of our other search experiments.",
        Download: "ZippedFiles/TLImages.zip",
        DownloadName: "TLImages.zip",
        downloadType: 'zip'
    },
]



async function downloadFromCDN(cdnUrl, filename = 'script.js') {
  try {
    const response = await fetch(cdnUrl);
    
    if (!response.ok) {
        alert('Download failed, please try again. \n' + response.statusText)
      throw new Error(`Failed to fetch file: ${response.statusText}`);
    }

    const blob = await response.blob();
    const blobUrl = window.URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = blobUrl;
    link.download = filename;
    link.style.display = 'none';
    
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    window.URL.revokeObjectURL(blobUrl);
    
  } catch (error) {
    console.error('Download failed:', error);
    alert('Download failed, please try again')
  }
}


for(let i = 0; i < tableObject.length; i++){
    const rowData = tableObject[i]
    const arow = document.createElement('tr')
    const name = document.createElement('td')
    
    const description = document.createElement('td')
    const descriptionText = document.createElement('div')

    const download = document.createElement('td')
    const downloadLink = document.createElement('a')
    const downloadButton = document.createElement('button')
    
    
    
    
    
    name.innerText = rowData.Name
    descriptionText.innerHTML = rowData.Description
    descriptionText.setAttribute('class', 'descriptionTextCell')
    description.setAttribute('class', 'descriptionCell')
    description.append(descriptionText)
    
    downloadButton.innerText = 'Download!'
    downloadButton.title = rowData.Name;
    


    if(rowData.downloadType == 'cdn'){
        downloadButton.addEventListener('click', async function(){
            downloadFromCDN(rowData.Download,rowData.DownloadName)            
        })

    }else{
        downloadLink.setAttribute('href', rowData.Download)
        downloadLink.setAttribute('download', rowData.DownloadName)
        
        downloadButton.addEventListener('click', function(){
            downloadLink.click()            
        })

    }

    

    download.append(downloadButton)
    
    //download.innerText = rowData.Download
    
    arow.append(name, description, download)
    downloadTableBody.appendChild(arow)
}


