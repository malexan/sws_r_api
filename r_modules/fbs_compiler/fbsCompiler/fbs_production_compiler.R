## Need to get all the elements associated with production
getProductionElement = function(measuredItemCPC){
    condition =
        paste0("WHERE cpc_code IN (",
               paste0(shQuote(as.character(measuredItemCPC)),
                      collapse = ", "), ")")
    yieldFormula =
        GetTableData(schemaName = "ess",
                     tableName = "item_yield_elements",
                     whereClause = condition)
    yieldFormula
}


## Get production data

getProductionData = function(){

    ## NOTE (Michael): Need to select all the items, waiting for response
    ##                 from Nick on the item table.
    productionKey = DatasetKey(
        domain = "agriculture",
        dataset = "agriculture",
        dimensions = list(
            Dimension(name = areaVar,
                      keys = selectedCountry),
            Dimension(name = elementVar,
                      keys = unique(productionElements$element_51)),
            Dimension(name = itemVar,
                      keys = primaryMeasuredItemCPC),
            Dimension(name = yearVar,
                      keys = selectedYear)
        )
    )

    ## Pivot to vectorize yield computation
    productionPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = itemVar, ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE),
        Pivoting(code = elementVar, ascending = TRUE)
    )

    ## Query the data
    ##
    ## NOTE (Michael): Need to check this, 570 items are queried, but only
    ##                 105 are returned. Also, there are no value for
    ##                 element 5518 which caused the type to be logical.
    productionQuery = GetData(
        key = productionKey,
        flags = TRUE,
        normalized = FALSE,
        pivoting = productionPivot
    )


    ## Convert time to numeric
    productionQuery[, timePointYears := as.numeric(timePointYears)]
    productionQuery
}


    

## NOTE (Michael): In order to build the production profile, we need
##                 to know how to calculate the "production". Do we
##                 include processed?  If no, then need the set of
##                 primary commodities, and meat for livestock; if
##                 yes, then we should only mapped to all the
##                 commodities which are within the standardization
##                 path.
        



## Pseudo codes:
##
## (1) Get all the production data excluding fishery

## (2) Get fishery production data (This step is no longer necessary
## as fishery will continue to produce their FBS in parallel)

## (3) Obtain oil seed and domestic consumption from UNSD, and compute
## food energy and crush rate (only for oil seed). The food energy is
## calculated as 'Food use dome. cons' mutliplied by 1000, but the
## unit is 1000 MT, there is no conversion to energy! The formula of
## the crush rate is recursive, we first calculate crush rate as
## (crush/domestic consumption), but then redefine crush as 1 - crush
## rate. The food calculation component should also be moved to food
## compiler.

## Adam: The quantity calculated is a different quantity not
## Crush. Use a different name.

## (4) Update the crush rate to the PrimaryAreaCode data, need to
## understand what this data is, and also the source of this data.

## (5) Merge the nutrient data from PrimaryAreaCode data with the
## production data.

## (6) Calculate the energy, calorie, lipid and CHOCDF of
## production. The raw does not include the crush rate, while the
## normal includes the application of the crush rate. Need to
## understand the difference and the implication of the two.

## (7) Calculate the residual for feed in calorie and protein. It is
## defined as production multiplied by (1 - extraction rate) then the
## nutrient conversion ratio. (This step should be moved to the feed
## compiler?)

## (8) Then aggregate the columns calculated in step (6) and (7) by
## area, year, group and commodity. Need to understand the difference
## between the use of group and commodity.


## The usda Crush is the quantity, this should be moved to the food
## module.


## Data check:
##
## (1) Where did the data set usdaData and usdaMap came from.
## 
##
##
## (2) The source of PrimaryAreaCodes.


## (1 - Extraction rate) is applied for feed, assuming everything not
## extracted goes to feed. Further, need to check the extraction rate
## for non ceral items.

## Should the edible applied to production? If the edible is applied
## to production, then the remaining should go to waste, however this
## is not done. The same logic applies to crush rate.

## The residual of the crush goes to industrial uses.

## Commodities is a subset of the group, need to double check the usage.

## Convert everything to energy, but protein is required for feed.
