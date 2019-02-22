# alcohol-calculator
[![Website sv.insysbio.com](https://img.shields.io/website-up-down-green-red/https/insysbio.shinyapps.io/alcohol_calculator/.svg)](https://insysbio.shinyapps.io/alcohol_calculator/)
[![GitHub license](https://img.shields.io/github/license/metelkin/alcohol-calculator.svg)](https://github.com/metelkin/alcohol-calculator/blob/master/LICENSE)

Shiny application to calculate alcohol in human blood

## start locally

```r
## create model
# MODEL <- ru.import.slv("al_07_05")		# import model from .SLV
## save model and create .c
# save(MODEL, file = "alc model.rumod")
compileCode <- paste0("R CMD SHLIB ", MODEL$dll, ".c")
system(compileCode)

shiny::runApp()
```
