# https://www.rselenium-teaching.etiennebacher.com/#/closing-selenium

library(RSelenium)

driver <- rsDriver(port = 4568L, browser = "firefox", chromever = NULL) # can also be "chrome"
remote_driver <- driver[["client"]]

# remote_driver$open()

remote_driver$navigate("http://www.google.com/ncr")
remote_driver$navigate("http://www.google.com/ncr")
remote_driver$getTitle()


driver$server$stop()


# # cosas para encontrar elementos
# remote_driver$
#   findElement("link text", "Contributors")$
#   clickElement()
# 
# remote_driver$
#   findElement("partial link text", "Contributors")$
#   clickElement()
# 
# remote_driver$
#   findElement("xpath", "/html/body/div/div[1]/div[1]/div/div[1]/ul/li[3]/a")$
#   clickElement()
# 
# remote_driver$
#   findElement("css selector", "div.col-xs-6:nth-child(1) > ul:nth-child(6) > li:nth-child(3) > a:nth-child(1)")$
#   clickElement()