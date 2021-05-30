# +
*** Settings ***
Documentation   Second robot for RoboCorp certification

Library  RPA.Browser.Selenium
Library  RPA.Excel.Files
Library  RPA.HTTP
Library  RPA.PDF
Library  RPA.Tables   
Library  RPA.Archive
Library  RPA.FileSystem
Library  RPA.Dialogs
Library  RPA.Robocloud.Secrets
# -


*** Keywords ***
Open Website in linked provided
    ${order_URL}=   Get Secret   credentials
    
    Open Available Browser  ${order_URL}[robo_orderURL]
    
    Click Button    OK

*** Keywords ***
Download orders
    [Arguments]     ${csv_url}
    
    RPA.HTTP.Download    ${csv_url}   overwrite=True
    
    #URL using -> https://robotsparebinindustries.com/orders.csv

*** Keywords ***
Capture excel file data
    ${order_form}=  Read table from CSV  orders.csv 
     
    FOR    ${row_head}    IN    @{order_form}
    
        IF    ${row_head}[Head] == ${1}
                Select From List By Label    id:head   Roll-a-thor head
        
            ELSE IF    ${row_head}[Head] == ${2}
                       Select From List By Label    id:head   Peanut crusher head
               
               ELSE IF    ${row_head}[Head] == ${3}
                          Select From List By Label    id:head   D.A.V.E head
                        
                     ELSE IF    ${row_head}[Head] == ${4}
                                Select From List By Label    id:head   Andy Roid head
                        
                            ELSE IF    ${row_head}[Head] == ${5}
                                       Select From List By Label    id:head   Spanner mate head
                        
                                 ELSE IF    ${row_head}[Head] == ${6}
                                            Select From List By Label    id:head   Drillbit 2000 head
                                     
        END
        
        IF    ${row_head}[Body] == ${1}
                Click Button     id:id-body-1   
        
            ELSE IF    ${row_head}[Body] == ${2}
                       Click Button     id:id-body-2   
               
               ELSE IF    ${row_head}[Body] == ${3}
                          Click Button     id:id-body-3   
                        
                     ELSE IF    ${row_head}[Body] == ${4}
                                Click Button     id:id-body-4   
                        
                            ELSE IF    ${row_head}[Body] == ${5}
                                       Click Button     id:id-body-5  
                        
                                 ELSE IF    ${row_head}[Body] == ${6}
                                            Click Button     id:id-body-6  
                                     
        END
        
        ${target_as_num}=  Convert To Integer    ${row_head}[Legs]
        Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${target_as_num}
        
        Input Text    id:address    ${row_head}[Address]
        
        Click Button    id:preview
        
    
        Wait Until Keyword Succeeds     10x      0.5sec     Click Order button     
        
        Convert to pdf      ${row_head}
        
        Screenshot and add to pdf       ${row_head}
        
        Click Button    id:order-another        
        
        Click Button    OK
        
    END  


*** Keywords ***
Click Order button
    Click Button  xpath://html/body/div/div/div[1]/div/div[1]/form/button[2]
    Wait Until Page Contains Element    id:receipt

*** Keywords ***
Convert to pdf
        [Arguments]     ${row_head}
        
        Wait Until Element Is Visible   id:receipt
        
        ${receipt_html}=     Get Element Attribute       id:receipt     outerHTML
        
        Html To Pdf     ${receipt_html}     ${CURDIR}${/}output${/}${row_head}[Order number].pdf

*** Keywords ***
Screenshot and add to pdf
        [Arguments]     ${row_head}
        
        Wait Until Element Is Visible   id:robot-preview-image
        
        Screenshot      id:robot-preview-image     ${CURDIR}${/}output${/}order${row_head}[Order number].png
        
        ${files_to_add}=    Create list    ${CURDIR}${/}output${/}${row_head}[Order number].pdf   ${CURDIR}${/}output${/}order${row_head}[Order number].png
        
        Add Files To Pdf        ${files_to_add}     ${CURDIR}${/}output${/}${row_head}[Order number].pdf
        
        Remove File      ${CURDIR}${/}output${/}order${row_head}[Order number].png


*** Keywords ***
Compile pdf in zip

        Archive Folder with Zip     ${CURDIR}${/}output     all_receipts.zip    include=*.pdf   

*** Keywords ***
Input dialog for csv url
        Create Form     CSV url to use
        Add text input  CSV url to use      urlinput
        ${result}=      Request Response
        [Return]    ${result["urlinput"]}

*** Keywords ***
Close Browser
    Close Browser

*** Tasks ***
Main workflow
    ${csv_url}=     Input dialog for csv url
    Open Website in linked provided
    Download orders    ${csv_url}
    Capture excel file data
    Compile pdf in zip  
    [Teardown]  Close All Browsers




