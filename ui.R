# Define UI
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Blood Alcohol Calculator"),

	#Panel for file uploading
	sidebarPanel(
	
	fileInput('file1', 'Choose CSV File',
	accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
	tags$hr(),
		
	#Personal parameters
	radioButtons("sex", "Sex:",
                 list("Male" = 1,
                      "Female" = 0),selected="Male"),

	numericInput("weight", "Weight (kg):", 70, min=1, max=400),
	numericInput("height", "Height (cm):", 175, min=20, max=400),
	numericInput("age", "Age (y):", 25, min=0, max=200),
	tags$hr(),
	
	#Alcohol Intake
  h3("Portion 1"),
	sliderInput("proof", "Proof (%):", 0, min=0, max=100, step=0.1),
	numericInput("volume", "Drunk Volume (ml):", 0, min=0),
	sliderInput("d_time", "Time (h):", min = 0, max = 24, value = 0, step=0.5),
	checkboxInput("add1", "Add another one"),
	tags$hr(),
  
	conditionalPanel(
	  condition = "input.add1 == true",
	  h3("Portion 2"),
	  sliderInput("proof1", "Proof (%):", 0, min=0, max=100, step=0.1),
	  numericInput("volume1", "Drunk Volume (ml):", 0, min=0),
	  sliderInput("d_time1", "Time (h):", min = 0, max = 24, value = 0, step=0.5),
	  checkboxInput("add2", "Add another one"),
	  tags$hr(),
    
	  conditionalPanel(
	    condition = "input.add2 == true",
	    h3("Portion 3"),
	    sliderInput("proof2", "Proof (%):", 0, min=0, max=100, step=0.1),
	    numericInput("volume2", "Drunk Volume (ml):", 0, min=0),
	    sliderInput("d_time2", "Time (h):", min = 0, max = 24, value = 0, step=0.5),
	    checkboxInput("add3", "Add another one"),
	    tags$hr(),
      
	    conditionalPanel(
	      condition = "input.add3 == true",
	      h3("Portion 4"),
	      sliderInput("proof3", "Proof (%):", 0, min=0, max=100, step=0.1),
	      numericInput("volume3", "Drunk Volume (ml):", 0, min=0),
	      sliderInput("d_time3", "Time (h):", min = 0, max = 24, value = 0, step=0.5)
        )
	  )
  )
	),

  mainPanel(
	plotOutput("BACplot"),
	sliderInput("time_scale", "Time period starting from first dose (h)", value = 1, min = 1, max = 24, step = 1),
	tags$br(),
#	conditionalPanel(
#		condition = "input.upl == true",
#		checkboxInput("fit_button", "Press to define Individual Parameters"),
#		conditionalPanel(
#			condition = "input.fit_button == true",
#			textOutput("Fit"))
#		),
	tableOutput("BACtable")
	)
))