# Working with cyREST on GSOC project using RCy3 with Cytoscape

This summer I had the pleasure of working with the National Resource for Network Biology ([NRNB](http://nrnb.org/index.html) as a summer intern as part of [Google Summer of Code project](https://summerofcode.withgoogle.com/projects/#6682250145955840) . For my project (described more in depth in the [previous blog post]( http://blog.lunean.com/2016/08/05/extending-rcy3-vignettes-google-summer-of-code-project/)) I wanted to make workflows for biologists to make their analyses more straightforward by using the programming language R with the Bioconductor package [RCy3](https://bioconductor.org/packages/release/bioc/html/RCy3.html).

Today I want to discuss a bit about my experience with GSOC and working with cyREST this summer. I will also list some of the forthcoming posts that will detail the projects that I worked on. 

## My experience

Overall, working with NRNB as part of Google summer of Code was a great experience. I interacted with many different people and was well supported by my mentor. It was a new challenge to work remotely on a project like this, but in the end I am happy with how it turned out. 

## The process

For Cytoscape to be accessible to users of different programming languages an API called [CyREST](https://github.com/cytoscape/cyREST) has been developed in Dr. Ideker's lab. More information about it is available in the [paper](http://f1000research.com/articles/4-478/v1), in the [Github repository](https://github.com/idekerlab/cyREST) and on this [website](http://idekerlab.github.io/cyREST/) that lists all the commands that are available in the API. 

CyREST is now available as part of Cytoscape when you download versions 3.3 and newer.

### Difficulties with CyREST

Generally I didn't have may problems using cyREST, but there were a few things that I struggled with. 

1. Saving images from Cytoscape via cyREST is dependent on the size of the window that you have open. You can use a parameter "h" which sets the size of the final image, but the width is set automatically. Therefore to get different sized or shaped images it is necessary to manipulate your open Cytoscape window to the shape that you want before running your commands via cyREST. 

2. Plugins in Cytoscape that present an API interface do not seem to have a standard verb-action vocabulary. I have to mention that developers that make these plugins are not under any obligation to do present an API interface (and it is more work for them). This is not a large difficulty, but it can require some guessing of how plugins can be used via cyREST and what commands are available from a specific plugin that can be used with cyREST. It can also be unclear why certain arguments are available in the app graphical interface and these are not available via cyREST. 

# Working with cyREST

To do this we identified plugins that present their APIs to cyREST and thus are able to be used on the command line and by the user from R.

Our main goal here was to create a reproducible analysis. However it is often not included in the documentation of the plugins or of Cytoscape what commands are available via the API so to find out what commands are available we needed to investigate.

## Ways to examine commands available via API

### Via command line tool in Cytoscape

Within Cytoscape, commands can be run using the command line dialog. 
![](./images/blog_post_2_tool-drop-down_command-line.png)

This is also where we can find out about commands by using the help associated with the different plugins and functions of Cytoscape. To examine what information is available, type in `help` into the command line box and press Enter (or Return).

![](./images/blog_post_2_command-line_help.png)

To look specifically at a specific command you can type `help` followed by the command (or plugin). If we type `help view` and press Enter (or Return) here we see:

![](./images/blog_post_2_command-line_help-view.png)

### Via your favourite internet browser

Your browser can also be used to examine the different commands available via the API. The default setting for the cyREST API has Cytoscape at localhost:1234. We will need to direct ourselves to the version 1 of cyREST as well. So if we do that, we get some details about Cytoscape and the API. 

This is because cyREST works as a Cytoscape app that exposes the data and functions in Cytoscape via an API. The REST API is an application programming interface that uses HTTP requests to send and receive data, so thus it is possible to examine what cyREST is exposing via your web browser.

![](./images/blog_post_2_chrome_api.png)

Side note: If we want to see a listing of the networks we have we can type: 

![](./images/blog_post_2_chrome_network.png)

Then to examine the possible commands available (like what we did with the command line dialogue above) we can type:

![](./images/blog_post_2_chrome_commands.png)

If we want to see the commands available within a set of commands we can type: 

![](./images/blog_post_2_chrome_commands_view.png)

You could indeed run commands from here, but this is not very practical and would defeat our purpose. This was just to show how to investigate the plugins and Cytoscape. We will switch to RCy3 in R to run the commands that we want to execute. 

### Using RCy3

In R, I have written code that allows me to also check on the commands available and the arguments available for these commands:

```r
library(RCy3)
source("./functions_to_add_to_RCy3/working_with_namespaces.R")
```

Test out the function to see what commands are available in Cytoscape

```r
cy <- CytoscapeConnection ()
getCommandNames(cy)
```

```
##  [1] "cluster"       "clusterviz"    "command"       "edge"         
##  [5] "enrichmentmap" "group"         "layout"        "network"      
##  [9] "node"          "session"       "table"         "view"         
## [13] "vizmap"
```
(Please note: Your view may be different if you have different plugins installed)
See what arguments are available within Cytoscape command “view”

```r
getCommandsWithinNamespace(cy, "view")
```

```
## [1] "create"       "destroy"      "export"       "fit content" 
## [5] "fit selected" "get current"  "list"         "set current" 
## [9] "update"
```

# Other summer activities: Poster presentation of GSOC work

I presented part of one of the workflows that I was working on at a scientific meeting this summer. The meeting was the Viruses of Microbes meeting in Liverpool, UK. Repository that contains the poster and code used to generate it are [here](https://github.com/jooolia/RCy3_VOM_poster). This was my first time creating and presenting a poster like this and it was quite enjoyable. 

# Blog posts to come:

In the next few weeks I will be posting more blog posts on the work that was done for the workflows. We will be releasing blog posts highlighting the different workflows that were created and with the help of the RCy3 developers we will be incorporating some of these workflows into RCy3.

## Topics of forthcoming blog posts:

- Enrichment Maps using Cytoscape plugin EMap
- Co-occurrence network using microbial data
- Using paxtoolsr to get information from Pathway Commons and display in Cytoscape
- Using chemviz to examine the chemical properties and structures of data and creating a network based on chemical similarity

In the meantime please feel free to check out my [final work submission](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/blog_post_drafts/final_work_submission.md) which describes the projects and links to the code used within them. 

