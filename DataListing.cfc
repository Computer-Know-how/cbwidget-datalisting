/**
* A widget that lists information from the ContentStore
*/
component extends="contentbox.model.ui.BaseWidget" singleton{

	DataListing function init(required any controller){
		// super init
		super.init( arguments.controller );

		// Widget Properties
		setPluginName( "DataListing" );
		setPluginVersion( "1.0" );
		setPluginDescription( "A widget that renders ContentStore data." );
		setPluginAuthor( "Computer Know How" );
		setPluginAuthorURL( "http://www.compknowhow.com" );
		setIcon( "window-text.png" );
		setCategory( "Content" );

		return this;
	}

	/**
	* Renders a file list
	* @category.label Category
	* @category.hint The category of the items from the ContentStore
	* @category.optionsUDF getCategoryList
	*
	* @fields.label Fields
	* @fields.hint The fields to include in the listing
	*
	* @sortField.label Sort Field
	* @sortField.hint The field to sort by intitially
	*
	* @sortOrder.label Sort Order
	* @sortOrder.hint The order to sort by intitially
	* @sortOrder.optionsUDF getSortOrders
	*
	* @groupLinks.label Add Group In Page Links?
	* @groupLinks.hint Display in page group linking?
	*
	* @grouping.label Setup Grouping?
	* @grouping.hint Group the list by the group custom field?
	*
	* @headerLevel.label Header Level
	* @headerLevel.hint The header level of the groups (h1, h2, h3...)
	* @headerLevel.optionsUDF getHeaderLevels
	*
	* @listingType.label Listing Type
	* @listingType.hint Type of listing
	* @listingType.optionsUDF getListingTypes
	*
	* @class.label Class
	* @class.hint Class(es) to apply to the listing table or list
	*/
	any function renderIt(required string category, string fields = "title,content", string sortField = "title", string sortOrder = "asc", boolean groupLinks = false, boolean grouping = false, numeric headerLevel = 3, string listingType = "table", string class="") {
		var event = getRequestContext();

		var local.sortField = event.getValue("sortField",arguments.sortField);
		var local.sortOrder = event.getValue("sortOrder",arguments.sortOrder);

		var rString = "";

		var listings = getListings(arguments.category,local.sortField,local.sortOrder);

		if (arguments.grouping) {
			var groups = getGroups(listings);
		}

		var iteration = 1;
		var currentGroup = "";

		var fieldsArray = listToArray(arguments.fields);

		saveContent variable="rString"{
			// group in page links
			if(arguments.groupLinks and arguments.grouping) {
				var groupCount = 0;

				writeOutput('<div class="group-links" style="margin-bottom:20px;">');
				for( var group in groups ) {
					groupCount++;
					writeOutput('<a href="#cb.linkSelf()###' & group & '">' & group & '</a>');
					if(groupCount < arrayLen(groups)) {
						writeOutput(' | ');
					}
				}
				writeOutput('</div>');
			}

			// loop over results and display
			for( var listing in listings ) {
				if(arguments.grouping) {
					if(listing.group neq currentGroup) {
						if(iteration gt 1) {writeOutput('</' & arguments.listingType & '>');}

						if(groupLinks) {
							writeOutput('<a name="' & listing.group & '"></a>');
						}

						writeOutput('<h' & arguments.headerLevel & '>' & listing.group & '</h' & arguments.headerLevel & '>');

						writeOutput('<' & arguments.listingType & ' class="' & arguments.class & '">');
						currentGroup = listing.group;
					}
				} else {
					if(iteration eq 1) {
						if(len(arguments.class)) {
							writeOutput('<' & arguments.listingType & ' class="' & arguments.class & '">');
						} else {
							writeOutput('<' & arguments.listingType & '>');
						}

						if(arguments.listingType eq 'table') {
							writeOutput('<thead><tr>');
							for( var field in fieldsArray ) {
								var oppositeDirection = ( local.sortOrder == "asc" ? "desc" : "asc" );
								var sortIcon = ( local.sortOrder == "asc" ? "fa-chevron-circle-down" : "fa-chevron-circle-up" );
								var link = cb.linkSelf() & "?sortField=#field#&sortOrder=#oppositeDirection#";

								if(local.sortField eq field) {
									writeOutput('<th><a href="#link#">#REReplace( field , "\b(\S)(\S*)\b" , "\u\1\L\2" , "all" )#</a> <i class="fa #sortIcon#"></i></th>');
								} else {
									writeOutput('<th><a href="#link#">#REReplace( field , "\b(\S)(\S*)\b" , "\u\1\L\2" , "all" )#</a></th>');
								}
							}
							writeOutput('</tr></thead>');
						}
					}
				}

				if(arguments.listingType eq 'ul') {
					var fieldIndex = 1;

					writeOutput('<li>');

					for( var field in fieldsArray ) {
						field = "listing." & field;

						writeOutput('#evaluate(field)#');

						if( fieldIndex lt arrayLen(fieldsArray) ) {
							writeOutput(' - ');
						}

						fieldIndex++;
					}

					writeOutput('</li>');

				} else if (arguments.listingType eq 'dl') {
					var fieldIndex = 1;

					for( var field in fieldsArray ) {
						field = "listing." & field;

						if( fieldIndex eq 1 ) {
							writeOutput('<dt>#evaluate(field)#</dt>');
						} else {
							writeOutput('<dd>#evaluate(field)#</dd>');
						}

						fieldIndex++;
					}

				} else if (arguments.listingType eq 'table') {
					writeOutput('<tr>');
					for( var field in fieldsArray ) {
						field = "listing." & field;
						writeOutput('<td>#evaluate(field)#</td>');
					}
					writeOutput('</tr>');

				} else if (arguments.listingType eq 'div' and arguments.class eq 'testimonials') {
					writeOutput('<blockquote>');
						var testimonial = "listing.content";
						var author = "listing.author";
						var company = "listing.company";

						writeOutput('#evaluate(testimonial)#');
						writeOutput('<cite><span class="author">#evaluate(author)#</span> #evaluate(company)#</cite>');
					writeOutput('</blockquote>');

				} else if (arguments.listingType eq 'div' and arguments.class eq 'accordion') {
					var question = "listing.title";
					var answer = "listing.content";

					writeOutput('<div class="panel panel-default">');
						writeOutput('<div class="panel-heading">');
							writeOutput('<h4 class="panel-title"><a data-parent="##accordion" data-toggle="collapse" href="##collapse-#category#-#iteration#" class="collapse" style="display: block;">#evaluate(question)#</a></h4>');
						writeOutput('</div>');
						writeOutput('<div class="panel-collapse collapse" id="collapse-#category#-#iteration#">');
							writeOutput('<div class="panel-body">');
								writeOutput('<p>#evaluate(answer)#</p>');
							writeOutput('</div>');
						writeOutput('</div>');
					writeOutput('</div>');
				}

				if(iteration eq arrayLen(listings)) {writeOutput('</' & arguments.listingType & '>');}

				iteration++;
			}
		}

		return rString;
	}

	/**
	* Return an array of ContentStore listings, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getListings(required string category, required string sortField, required string sortOrder){
		var listings = [];

		// get content store data in the specified category
		if(len(arguments.category)) {
			var contentStoreData = contentStoreService.findPublishedContent( category=arguments.category );
		} else {
			var contentStoreData = contentStoreService.findPublishedContent();
		}

		for( var item in contentStoreData.content ) {
			// get root details that we care about
			var data = {
				"title" = item.getTitle(),
				"content" = item.getContent(),
				"contentID" = item.getContentID(),
				"slug" = item.getSlug(),
				"group" = ""
			};

			// check that there are custom fields first
			if( item.hasCustomField() ) {
				// get custom field data as a struct and append it to our data
				var custom = item.getCustomFieldsAsStruct();
				structAppend( data, custom );
			}

			// add the item to our array; now we have a nice array of structs to use however
			arrayAppend( listings, data );
		}

		return arrayOfStructsSort(listings, arguments.sortField, arguments.sortOrder);
	}

	/**
	* Return an array of groups, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getGroups(listings){
		var groups = [];

		for( var listing in arguments.listings ) {
			if(!arrayFind(groups, listing.group)) {
				// add the group to our array
				arrayAppend(groups, listing.group);
			}
		}

		return groups;
	}

	/**
	* Return an array of categories, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getCategoryList(){
		var categories = categoryService.getAllNames();
		arrayPrepend(categories,"");

		return categories;
	}

	/**
	* Return an array of listing types, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getSortOrders(){
		return ["asc","desc"];
	}

	/**
	* Return an array of listing types, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getHeaderLevels(){
		return [1,2,3,4,5,6];
	}

	/**
	* Return an array of listing types, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*/
	array function getListingTypes(){
		return ["ul","dl","table","div"];
	}

	/**
	* Sorts an array of structures based on a key in the structures, the @ignore annotation means the ContentBox widget editors do not use it only used internally.
	* @cbignore
	*
	* @param aofS - Array of structures. (Required)
	* @param key - Key to sort by. (Required)
	* @param sortOrder - Order to sort by, asc or desc. (Optional)
	* @param sortType - Text, textnocase, or numeric. (Optional)
	* @param delim - Delimiter used for temporary data storage. Must not exist in data. Defaults to a period. (Optional)
	*
	* @return Returns a sorted array.
	* @author Nathan Dintenfass (nathan@changemedia.com)
	* @version 1, April 4, 2013
	*/
	function arrayOfStructsSort(required aOfS, required key){
		//by default we'll use an ascending sort
		var sortOrder = "asc";
		//by default, we'll use a textnocase sort
		var sortType = "textnocase";
		//by default, use ascii character 30 as the delim
		var delim = ".";
		//make an array to hold the sort stuff
		var sortArray = arraynew(1);
		//make an array to return
		var returnArray = arraynew(1);
		//grab the number of elements in the array (used in the loops)
		var count = arrayLen(aOfS);
		//make a variable to use in the loop
		var ii = 1;
		//if there is a 3rd argument, set the sortOrder
		if(arraylen(arguments) GT 2)
		    sortOrder = arguments[3];
		//if there is a 4th argument, set the sortType
		if(arraylen(arguments) GT 3)
		    sortType = arguments[4];
		//if there is a 5th argument, set the delim
		if(arraylen(arguments) GT 4)
		    delim = arguments[5];
		//loop over the array of structs, building the sortArray
		for(ii = 1; ii lte count; ii = ii + 1)
		    sortArray[ii] = aOfS[ii][key] & delim & ii;
		//now sort the array
		arraySort(sortArray,sortType,sortOrder);
		//now build the return array
		for(ii = 1; ii lte count; ii = ii + 1)
		    returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
		//return the array
		return returnArray;
	}

}