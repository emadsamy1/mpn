*** Settings ***
Library           SeleniumLibrary
Library           Collections
Library           JSONLibrary
Library           BuiltIn
Resource         utils.robot

*** Variables ***
${ARTICLE_JSON_PATH}    ${PROJ_PATH}/proj/${ENVIRONMENT}_articles.json

*** Keywords ***
Navigate To Article Page
    [Arguments]    ${url}
    [Documentation]    Navigates to the given article page.
    ${data}    Load JSON From File    ${ARTICLE_JSON_PATH}
    ${article_url}    Get From Dictionary    ${data}    ${url}
    Go To    ${article_url}
    Wait Until Page Contains    Article Title    timeout=10s

View Test Article
    [Arguments]    ${article_name}
    [Documentation]    Opens the specified test article.
    ${now}    Get Current Date    result_format=%Y/%m/%d
    Navigate To    /archive/${now}/${article_name}

Verify Valid Date Format
    [Documentation]    Ensures the date format on the page is correct.
    ${now}    Get Current Date    result_format=%d %B %Y
    Element Should Contain    xpath=//div[@class='date-container']    ${now}

Check Related Articles Count
    [Arguments]    ${expected_count}
    [Documentation]    Validates the number of related articles displayed.
    ${related_articles}    Get Element Count    xpath=//div[@class='article__related-content']//*[contains(@id, 'article-start')]
    Should Be Equal As Numbers    ${related_articles}    ${expected_count}

Wait For Related Content To Load
    [Documentation]    Waits until the related content section is fully loaded.
    Wait Until Element Is Not Visible    xpath=//div[@class='ajax-progress ajax-progress-throbber']    timeout=20s

Verify Selected Author
    [Arguments]    ${author_name}
    [Documentation]    Checks if the selected author is displayed.
    Element Should Contain    xpath=//div[@class='author-container']    ${author_name}

Verify Share Popup Displayed
    [Arguments]    ${platform}
    [Documentation]    Ensures the share popup is displayed.
    Wait Until Page Contains Element    xpath=//div[contains(@class, '${platform}-popup')]    timeout=10s

Switch To Share Popup
    [Documentation]    Switches to the opened share popup window.
    Switch Window    NEW

Close Share Popup
    [Documentation]    Closes the share popup window.
    Close Window
    Switch Window    MAIN

Store Article URL
    [Documentation]    Saves the current article URL to the JSON file.
    ${url}    Get Location
    ${data}    Load JSON From File    ${ARTICLE_JSON_PATH}
    Set To Dictionary    ${data}    ${url.split('/')[-1]}=${url.split('.com/')[-1]}
    Dump JSON To File    ${ARTICLE_JSON_PATH}    ${data}

Scroll Page To Load Related Articles
    [Arguments]    ${times}
    [Documentation]    Scrolls down multiple times to load all related articles.
    FOR    ${index}    IN RANGE    ${times}
        Scroll Element Into View    xpath=//div[@class='article__related-content']//*[contains(@id, 'article-start')]
        Sleep    1s
    END
