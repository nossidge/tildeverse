
// Find the difference of two arrays
// https://stackoverflow.com/a/4026828/139299
Array.prototype.diff = function(a) {
  return this.filter( function(i) {
    return a.indexOf(i) < 0;
  });
};

//##############################################################################

// Return a formatted string from a date
// Return '-' if the date is invalid
function dateYYYYMMDD(date) {
  if (isNaN(date)) return "-";
  let year = date.getFullYear();
  let month = "" + (date.getMonth() + 1);
  let day = "" + date.getDate();
  if (month.length < 2) month = "0" + month;
  if (day.length < 2) day = "0" + day;
  return [year, month, day].join("-");
}

//##############################################################################

// Turn an array into an iterator
function toIterator(array) {
  let index = -1;

  return {
    index: function() {
      return parseInt(index);
    },
    all: function() {
      return array;
    },
    current: function() {
      return (index >= 0 && index < array.length) ?
        { value: array[index], done: false } :
        { done: true };
    },
    next: function() {
      if (index < array.length - 1) {
        return { value: array[++index], done: false };
      } else {
        index = array.length;
        return { done: true };
      }
    },
    previous: function() {
      if (index > 0) {
        return { value: array[--index], done: false };
      } else {
        index = -1;
        return { done: true };
      }
    },
    random: function() {
      index = Math.floor(Math.random() * array.length);
      return array[index];
    },
    gotoIndex: function(inputIndex) {
      index = inputIndex;
      return array[index];
    },
    gotoValue: function(inputValue) {
      index = array.indexOf(inputValue);
      return array[index];
    }
  };
}

//##############################################################################

// UI improvements for accessibility
var ACCESSIBILITY = ( function(mod) {

  // For anchors with a 'tabindex', call 'onclick' when space/enter is pressed
  // Only run this when all DOM elements are loaded
  mod.tabNavClicks = function() {
    $("a[tabindex]").each( function() {
      $(this).keydown(function(e) {
        if (e.key == " " || e.key == "Enter") {
          e.preventDefault();
          $(this).triggerHandler("click");
        }
      });
    });
  };

  // Hacky fix to keep the heights correct
  mod.fixHeights = function() {
    let heightDiff = 89;
    let btnCount = INFO.tagsCount + 1;
    let btnHeightAll = $(window).height() - heightDiff;
    let btnHeight = (btnHeightAll / btnCount) + "px";
    $(".tag_button_desc").css("height", btnHeight);
    $(".tag_button").css("height", btnHeight);
    $(".btn_glyph").css("height", btnHeight);
    $(".btn_tags").css("height", btnHeight);
    $("#list_text").css("max-height", "0px");
    let columnHeight = $("#col_left").css("height");
    $("#list_text").css("max-height", columnHeight);
  };

  return mod;
}(ACCESSIBILITY || {}));

//##############################################################################

// Module to store the info about each tag
var INFO = ( function(mod) {

  mod.tags = {
    empty:    "No content / default index.html",
    brief:    "Not a lot of content",
    redirect: "No content; page just links to elsewhere on the Web",
    links:    "Links to personal sites elsewhere",
    blog:     "An old-fashioned weblog",
    poetry:   "Verse in any form",
    prose:    "Fiction or nonfiction, in sufficient quantity",
    art:      "Any form of art. Includes ASCII, JS and HTML. Words can be art",
    photo:    "Photography",
    audio:    "Music, spoken word, sound",
    video:    "Moving pictures",
    gaming:   "Stuff about games",
    tutorial: "An in-depth guide to a topic",
    app:      "Web application of any kind",
    code:     "Contains actual code samples/projects",
    procgen:  "Procedurally generated art/poetry/music/whatever",
    "web1.0": "Early web aesthetic",
    unix:     "Unix and terminal",
    tilde:    "Meta stuff, to do with the Tildeverse"
  };

  // Count the number of tags
  mod.tagsCount = Object.keys(mod.tags).length;

  // These sites have 'X-Frame-Options' set to 'sameorigin'
  mod.banned = ["tilde.team", "thunix.org"];

  return mod;
}(INFO || {}));

//##############################################################################

// Module to read and set tag info
var TAG_DOM = ( function(mod) {

  // For the 'browser' webapp:
  mod.createTagElementsBrowser = function() {
    let templateHTML = `
      <div class="btn-group btn-block" title="@DESC@" data-tag-name="@TAG@">
        <a id="tag_button_unchecked_@TAG@"
           class="btn btn-default btn-lg btn_glyph tag_button_unchecked"
           title="Exclude the '@TAG@' tag"
           data-filter-type="unchecked"
           tabindex="@INDEX@1"
           onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-remove"></div>
        </a>
        <a id="tag_button_checked_@TAG@"
           class="btn btn-default btn-lg btn_glyph tag_button_checked"
           title="Include the '@TAG@' tag"
           data-filter-type="checked"
           tabindex="@INDEX@2"
           onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-ok"></div>
        </a>
        <div id="tag_button_desc_@TAG@"
             class="btn btn-default btn-lg tag_button_desc no_pointer_events"
             title="(This is not actually a button)"
             data-tag-name="@TAG@">
          @TAG@
        </div>
      </div>
    `;
    replaceTemplateKeywords(templateHTML);
  };

  // For the 'tagging' webapp:
  mod.createTagElementsTagging = function() {
    let templateHTML = `
      <a id="tag_button_@TAG@"
         class="btn btn-default btn-lg btn_tags tag_button tag_button_desc"
         title="@DESC@"
         data-tag-name="@TAG@"
         onclick="TAG_STATE.toggleTag(this);">
        @TAG@
      </a>
    `;
    replaceTemplateKeywords(templateHTML);
  };

  // Create and append the HTML elements for the tag buttons
  function replaceTemplateKeywords(templateHTML) {
    let elem = $("#tag_buttons");
    elem.empty();
    let index = 2;
    $.each(INFO.tags, function(tag, desc) {
      let tagHtml = templateHTML;
      tagHtml = tagHtml.replace(/@TAG@/g, tag);
      tagHtml = tagHtml.replace(/@DESC@/g, desc);
      tagHtml = tagHtml.replace(/@INDEX@/g, index + 2);
      elem.append(tagHtml);
      index++;
    });
  }

  // Return the status of the tags selected on the UI
  mod.getDesc = function() {
    return mod.getTagsByType("desc");
  };
  mod.getChecked = function() {
    return mod.getTagsByType("checked");
  };
  mod.getUnchecked = function() {
    return mod.getTagsByType("unchecked");
  };
  mod.getTagsByType = function(tagType) {
    let tags = [];
    $(".tag_button_" + tagType).each( function() {
      if ($(this).hasClass("active")) {
        let tagName = $(this).parent().attr("data-tag-name");
        tags.push(tagName);
      }
    });
    return tags;
  };

  // Handle the header 'select all' buttons
  mod.allChecked = function() {
    return (mod.getChecked().length == INFO.tagsCount);
  };
  mod.allUnchecked = function() {
    return (mod.getUnchecked().length == INFO.tagsCount);
  };
  mod.handleSelectAllButtons = function() {
    if (mod.allUnchecked()) {
      $("#toggle_all_unchecked").addClass("active");
    } else {
      $("#toggle_all_unchecked").removeClass("active");
    }
    if (mod.allChecked()) {
      $("#toggle_all_checked").addClass("active");
    } else {
      $("#toggle_all_checked").removeClass("active");
    }
  };

  // Display the users tags as active/inactive description buttons
  mod.displayTags = function(tags) {
    $(".tag_button_desc").each( function() {
      $(this).removeClass("active");
    });
    if (!tags) return;
    $.each(tags, function(index, tag) {
      let elem = $(".tag_button_desc[data-tag-name='" + tag + "']");
      elem.addClass("active");
    });
  };

  // Toggle an button active state
  // Also unchecks the opposite button
  // Afterwards, filter by selected tags
  mod.toggleTagFilter = function(element) {
    let thisFilter = $(element).attr("data-filter-type");
    let thatFilter = (thisFilter == "checked" ? "unchecked" : "checked");
    let opposite = $(element).parent().find(".tag_button_" + thatFilter);
    $(opposite).removeClass("active");
    $(element).toggleClass("active");
    FILTER.setTags(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
    QUERY_STRING.browserWrite();
  };

  return mod;
}(TAG_DOM || {}));

//##############################################################################

// Module to store user arrays
var USERS = ( function(mod) {
  let all = [];
  let filtered = null;

  // Set the underlying user array from the JSON object
  // Convert JSON into an array of hashes
  // Save to 'all' instance variable
  mod.initialize = function(value) {
    all = [];
    let allSites = value["sites"];
    for (let site in allSites) {
      let url       = allSites[site]["url_format_user"];
      let siteUsers = allSites[site]["users"];
      for (let user in siteUsers) {
        let tags = siteUsers[user]["tags"];
        let date_tagged   = new Date(siteUsers[user]["date_tagged"]);
        let date_modified = new Date(siteUsers[user]["date_modified"]);
        let obj = {
          site: site,
          user: user,
          url: url.replace("USER", user),
          date_tagged: date_tagged,
          date_modified: date_modified,
          tags: tags
        };
        all.push(obj);
      }
    }
  };

  // Getter only
  mod.all = function() {
    return all;
  };

  // Reference to the current user
  mod.currentUser = function() {
    if (!filtered) return false;
    return filtered.current().value;
  };

  // Basic getter/setter
  mod.filtered = function(value) {
    if (typeof value !== "undefined") {
      filtered = value;
      URL_NAVIGATION.data(value);
      populateDropdownURLs();
    }
    return filtered;
  };

  // Display all the user's info on screen
  mod.displayCurrentUser = function() {
    VIEW.iframe();
    let user = mod.currentUser();

    if (typeof user !== "undefined") {
      mod.openCurrentInFrame();
      TAG_DOM.displayTags(user.tags);
      $("#text_user").attr("value", user.url);

      // Show dates as tooltips
      let tooltip = "@TAG@ - tagged\n@MOD@ - modified";
      tooltip = tooltip.replace(/@TAG@/g, dateYYYYMMDD(user.date_tagged));
      tooltip = tooltip.replace(/@MOD@/g, dateYYYYMMDD(user.date_modified));
      $("#text_user").attr("title", tooltip);
      $("#text_counter").attr("title", tooltip);

      let index = USERS.filtered().index();
      document.getElementById("url_dropdown").value = index;
      let counter = (index + 1) + "/" + USERS.filtered().all().length;
      $("#text_counter").attr("value", counter);
    } else {
      TAG_DOM.displayTags([]);
      $("#text_user").attr("value", "No users found!");
      $("#text_counter").attr("value", "");
    }
  };

  // Open the current Tilde user site in the iframe
  mod.openCurrentInFrame = function() {
    if (typeof mod.currentUser() !== "undefined") {
      let elem = document.getElementById("url_iframe_link");
      elem.href = mod.currentUser().url;
      elem.click();
    }
  };

  // Open the current Tilde user site in a new tab
  mod.openCurrentInNewTab = function() {
    if (typeof mod.currentUser() !== "undefined") {
      let elem = document.getElementById("url_blank_link");
      elem.href = mod.currentUser().url;
      elem.click();
    }
  };

  // Populate the input selection with the URLs
  function populateDropdownURLs() {
    let elem = $("#url_dropdown");
    elem.empty();
    $.each(filtered.all(), function(index, obj) {
      let url = obj.url.substring(obj.url.search("//") + 2);
      elem.append("<option value='" + index + "'>" + url + "</option>");
    });
  }

  return mod;
}(USERS || {}));

//##############################################################################

// Store which filter settings are currently in place
var FILTER = ( function(mod) {
  let filterName = "all"
  let tagsInclude = [];
  let tagsExclude = [];

  // Return the current filter name
  mod.name = function() {
    return filterName;
  };

  // Set a named filter
  mod.setAll = function() {
    setFilterNameAndApply("all");
  };
  mod.setNewlyUpdated = function() {
    setFilterNameAndApply("newly_updated");
  };
  mod.setNeverTagged = function() {
    setFilterNameAndApply("never_tagged");
  };
  mod.setExcludingBanned = function() {
    setFilterNameAndApply("excluding_banned");
  };

  // Set a group of tags to include and/or exclude
  mod.setTags = function(include, exclude) {
    tagsInclude = include;
    tagsExclude = exclude;
    apply();
  };

  // Set the filtername and then apply the filter
  function setFilterNameAndApply(value) {
    filterName = value;
    apply();
  }

  // Apply the given filters to the user list
  function apply() {
    let baseArray = USERS.all();
    switch (filterName) {
      case "newly_updated":
        baseArray = FILTER_FUNCTIONS.getNewlyUpdated();
        break;
      case "never_tagged":
        baseArray = FILTER_FUNCTIONS.getNeverTagged();
        break;
      case "excluding_banned":
        baseArray = FILTER_FUNCTIONS.getExcludingBanned();
    }
    FILTER_FUNCTIONS.byTag(baseArray, tagsInclude, tagsExclude);
    QUERY_STRING.browserWrite();
  }

  return mod;
}(FILTER || {}));

//##############################################################################

// Module to filter USER arrays by various means
var FILTER_FUNCTIONS = ( function(mod) {

  // Filter the homepage list by specific tags
  // Also updates the page elements
  // @param tagsInclude [Array<String>]
  // @param tagsExclude [Array<String>]
  mod.byTag = function(baseArray, tagsInclude = [], tagsExclude = []) {
    let originalUser = USERS.currentUser();

    TAG_DOM.handleSelectAllButtons();
    let newList = toIterator(baseArray);
    if (tagsInclude != []) {
      newList = toIterator(
        newList.all().filter( function(user) {
          return tagsInclude.diff(user.tags).length === 0;
        })
      );
    }
    if (tagsExclude != []) {
      newList = toIterator(
        newList.all().filter( function(user) {
          let diff = user.tags.diff(tagsExclude);
          return JSON.stringify(diff) == JSON.stringify(user.tags)
        })
      );
    }
    USERS.filtered(newList);

    // If the current view is "list", then remake the table
    if (VIEW.current() == "list") {
      VIEW.list();
    } else {
      gotoOriginal(newList, originalUser);
    }
  };

  // Return users whose modified date is greater than their tagged date
  let getNewlyUpdatedMemo = null;
  mod.getNewlyUpdated = function() {
    return addMemo("getNewlyUpdatedMemo", function(user) {
      return USERS.all().filter( function(user) {
        return (user.date_modified > user.date_tagged);
      });
    });
  };

  // Return users who have never been tagged
  let getNeverTaggedMemo = null;
  mod.getNeverTagged = function() {
    return addMemo("getNeverTaggedMemo", function(user) {
      return USERS.all().filter( function(user) {
        let strTags = JSON.stringify(user.tags);
        let isHyphen = (strTags == JSON.stringify(["-"]));
        let isEmpty  = (strTags == JSON.stringify([]));
        return (isHyphen || isEmpty);
      });
    });
  };

  // Return users who are not banned from cross-origin iframe
  // Also, tilde.town is over HTTPS, so exclude all sites that are HTTP
  let getExcludingBannedMemo = null;
  mod.getExcludingBanned = function() {
    return addMemo("getExcludingBannedMemo", function(user) {
      return USERS.all().filter( function(user) {
        let isBannedSite = INFO.banned.includes(user.site);
        let isHTTP = user.url.startsWith("http://");
        return (!isBannedSite && !isHTTP);
      });
    });
  };

  // If the original user still exists in the filtered dataset,
  // then keep them selected. Else, go to the first URL
  function gotoOriginal(newList, originalUser) {
    if (originalUser) {
      let found = newList.all().find( function(user) {
        return user.url == originalUser.url;
      });
      if (typeof found !== "undefined") {
        URL_NAVIGATION.gotoUrlOfUser(found);
      } else {
        URL_NAVIGATION.nextUrl();
      }
    } else {
      URL_NAVIGATION.nextUrl();
    }
  }

  // Add memoization to the callback function
  function addMemo(memoVar, callback) {
    let memo = eval(memoVar);
    if (memo) return memo;
    let output = callback();
    eval(memoVar + " = output;");
    return output;
  }

  return mod;
}(FILTER_FUNCTIONS || {}));

//##############################################################################

// Module to control the top-left URL navigation buttons
var URL_NAVIGATION = ( function(mod) {

  // The iterator object that contains the underlying data
  let data = null;
  mod.data = function(value) {
    if (typeof value !== "undefined") data = value;
    return data;
  };

  mod.nextUrl = function() {
    let user = data.next().value;
    if (!user) data.previous().value;
    USERS.displayCurrentUser();
  };
  mod.previousUrl = function() {
    let user = data.previous().value;
    if (!user) data.next().value;
    USERS.displayCurrentUser();
  };
  mod.randomUrl = function() {
    data.random();
    USERS.displayCurrentUser();
  };
  mod.gotoUrlIndex = function(index) {
    data.gotoIndex(index);
    USERS.displayCurrentUser();
  };
  mod.gotoUrlOfUser = function(user) {
    data.gotoValue(user);
    USERS.displayCurrentUser();
  };

  return mod;
}(URL_NAVIGATION || {}));

//##############################################################################

// Module to handle buttons that act like option groups
var TOGGLE_GROUPS = ( function(mod) {

  // Handle the tag select/deselect all buttons
  mod.toggleAllUnchecked = function(self) {
    toggleEither(self, ".tag_button_unchecked", ".tag_button_checked");
    FILTER.setTags(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };
  mod.toggleAllChecked = function(self) {
    toggleEither(self, ".tag_button_checked", ".tag_button_unchecked");
    FILTER.setTags(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };
  function toggleEither(self, activeElements, linkedElements) {
    if ($(self).hasClass("active")) {
      MASS_CLASS.remove(activeElements, "active");
    } else {
      MASS_CLASS.add(activeElements, "active");
      MASS_CLASS.remove(linkedElements, "active");
    }
  }

  // Handle the exclude cross requests button
  mod.toggleExcludingBanned = function() {
    let elem = $("#filter_by_excluding_banned");
    if (elem.hasClass("active")) {
      elem.removeClass("active");
      FILTER.setAll();
    } else {
      elem.addClass("active");
      FILTER.setExcludingBanned();
    }
  };

  // Handle the filter by tag/moddate buttons
  mod.toggleNeverTagged = function() {
    MASS_CLASS.add("#filter_by_never_tagged", "active");
    MASS_CLASS.remove("#filter_by_newly_updated", "active");
    FILTER.setNeverTagged();
  };
  mod.toggleNewlyUpdated = function() {
    MASS_CLASS.add("#filter_by_newly_updated", "active");
    MASS_CLASS.remove("#filter_by_never_tagged", "active");
    FILTER.setNewlyUpdated();
  };

  return mod;
}(TOGGLE_GROUPS || {}));

//##############################################################################

// Module to add/remove class for many elements at once
var MASS_CLASS = ( function(mod) {

  mod.add = function(domIdentifier, className) {
    $(domIdentifier).each( function() { $(this).addClass(className); })
  }
  mod.remove = function(domIdentifier, className) {
    $(domIdentifier).each( function() { $(this).removeClass(className); })
  }

  return mod;
}(MASS_CLASS || {}));

//##############################################################################

// Module to control the tag states for the Tagger site
var TAG_STATE = ( function(mod) {
  let savedTags = {};

  // Toggle a tag button active state, and save to state
  mod.toggleTag = function(element) {
    if (USERS.currentUser()) {
      $(element).toggleClass("active");
      mod.saveTagsToState();
      saveDirty();

      // Add to {savedTags}
      let tildee = USERS.currentUser();
      if (typeof(savedTags[tildee.site]) === "undefined") {
        savedTags[tildee.site] = {};
      }
      savedTags[tildee.site][tildee.user] = tildee.tags;
    }
  };

  // Save the current tag layout to the current user
  mod.saveTagsToState = function() {
    if (USERS.currentUser()) {
      let tags = [];
      $("#tag_buttons a").each( function() {
        if ($(this).hasClass("active")) {
          let tagName = $(this).attr("data-tag-name");
          tags.push(tagName);
        }
      });
      USERS.currentUser().tags = tags;
    }
  };

  // Post the {savedTags} hash to '/save_tags' route
  mod.saveTagsToFile = function() {
    $.post("save_tags", JSON.stringify(savedTags));
    savedTags = {};
    saveClean();
  };

  // Change the glyphicon floppy disk of the 'save tags' button
  function saveDirty() {
    let elem = $("#save_glyphicon");
    elem.removeClass("glyphicon-floppy-saved");
    elem.addClass("glyphicon-floppy-disk");
  }
  function saveClean() {
    let elem = $("#save_glyphicon");
    elem.removeClass("glyphicon-floppy-disk");
    elem.addClass("glyphicon-floppy-saved");
  }

  return mod;
}(TAG_STATE || {}));

//##############################################################################

// Module to switch the content in the main div
var VIEW = ( function(mod) {
  let current = "iframe";

  mod.current = function() {
    return current;
  };

  // Display the iframe with the embedded Tildesite
  mod.iframe = function() {
    if (current == "iframe") return;
    current = "iframe";
    elemShow("#tildesite_iframe");
    elemHide("#help_text");
    elemHide("#list_text");
    $("#help_btn").removeClass("active");
    $("#list_btn").removeClass("active");
    USERS.displayCurrentUser();
  };

  // Diplay the help text
  mod.help = function() {
    current = "help";
    elemHide("#tildesite_iframe");
    elemShow("#help_text");
    elemHide("#list_text");
    $("#help_btn").addClass("active");
    $("#list_btn").removeClass("active");
    TAG_DOM.displayTags([]);
    clearTopBarInfo("Info screen");
  };

  // Diplay the selected users in a table list
  mod.list = function() {
    current = "list";
    elemHide("#tildesite_iframe");
    elemShow("#list_text");
    elemHide("#help_text");
    $("#help_btn").removeClass("active");
    $("#list_btn").addClass("active");
    TAG_DOM.displayTags([]);
    clearTopBarInfo("User list");
    DATA_TABLE.make();
  };

  // The button toggle events that switch the view
  mod.helpToggle = function() {
    $("#help_btn").hasClass("active") ? VIEW.iframe() : VIEW.help();
  };
  mod.listToggle = function() {
    $("#list_btn").hasClass("active") ? VIEW.iframe() : VIEW.list();
  };

  // Use CSS classes to show or hide an element
  function elemHide(elemID) {
    $(elemID).addClass("hidden");
    $(elemID).removeClass("visible");
  }
  function elemShow(elemID) {
    $(elemID).addClass("visible");
    $(elemID).removeClass("hidden");
  }

  // Empty the top bar of user details and display the current view title
  function clearTopBarInfo(displayText) {
    $("#text_user").attr("value", displayText);
    $("#text_counter").attr("value", "");
    document.getElementById("url_dropdown").value = null;
  }

  return mod;
}(VIEW || {}));

//##############################################################################

// Module to create and display the table of users
var DATA_TABLE = ( function(mod) {
  let sortOrder = [3, "desc"];
  let pageLength = 20;
  let searchText = "";

  mod.make = function() {
    makeHTML();
    applyDataTable();
  };

  function makeHTML() {
    let thead = `
      <thead>
        <tr>
          <th>Tilde Box</th>
          <th>User Name</th>
          <th>User URL</th>
          <th>Modified</th>
        </tr>
      </thead>`;
    let tbody = document.createElement("tbody");
    $("#list_table").empty();
    $("#list_table").append(thead);
    $("#list_table").append(tbody);
    let row = `
      <tr>
        <td><a href="SITE_URL">SITE_NAME</a></td>
        <td>USER_NAME</td>
        <td><a href="USER_URL">USER_URL_TIDY</a></td>
        <td>MODIFIED</td>
      </tr>`;
    $.each(URL_NAVIGATION.data().all(), function(index, user) {
      let tidy = user.url.substring(user.url.indexOf("//") + 2);
      let scheme = user.url.split("/")[0];
      let siteUrl = scheme + "//" + user.site;
      let out = row;
      out = out.replace("SITE_URL",      siteUrl);
      out = out.replace("SITE_NAME",     user.site);
      out = out.replace("USER_NAME",     user.user);
      out = out.replace("USER_URL",      user.url);
      out = out.replace("USER_URL_TIDY", tidy.replace(/\/$/, ""));
      out = out.replace("MODIFIED",      dateYYYYMMDD(user.date_modified));
      $(tbody).append(out);
    });
  }

  function applyDataTable() {
    let table = $("#list_table").DataTable({
      "bDestroy": true,
      "aLengthMenu": [
        [10, 20, 50, 100, 200, 500, -1],
        [10, 20, 50, 100, 200, 500, "All"]
      ],
      "order": sortOrder,
      "pageLength": pageLength,
      "search": {
        "search": searchText
      }
    });
    table.on("order.dt", function(_1, _2, edit) {
      sortOrder = [edit[0].col, edit[0].dir];
    });
    table.on("length.dt", function(_1, _2, len) {
      pageLength = len;
    });
    table.on("search.dt", function() {
      searchText = table.search();
    });
  }

  return mod;
}(DATA_TABLE || {}));

//##############################################################################

// Read/write to/from the URL query string
var QUERY_STRING = ( function(mod) {
  let paramTagInclude  = "y";
  let paramTagExclude  = "n";
  let paramCrossOrigin = "x";

  // Read the query for the browser page
  mod.browserRead = function() {
    let params = new URLSearchParams(location.search);
    let tagsY = params.get(paramTagInclude);
    let tagsN = params.get(paramTagExclude);
    let xOrig = (params.get(paramCrossOrigin) == "true");

    // Apply the query tags to the app
    if (tagsY || tagsN || xOrig) {
      tagsY = (tagsY ? tagsY.split(",") : []);
      tagsN = (tagsN ? tagsN.split(",") : []);

      toggleTags = function(tags, status) {
        for (let tag of tags) {
          let button = $("#tag_button_" + status + "_" + tag);
          if (button.length) TAG_DOM.toggleTagFilter(button);
        }
      };
      toggleTags(tagsY, "checked");
      toggleTags(tagsN, "unchecked");

      if (xOrig) TOGGLE_GROUPS.toggleExcludingBanned();

      VIEW.list();

    // By default, filter by:
    //   - excluding denied XReqs
    //   - excluding the 'empty' tag
    } else {
      TOGGLE_GROUPS.toggleExcludingBanned();
      TAG_DOM.toggleTagFilter($("#tag_button_unchecked_empty"));
      URL_NAVIGATION.randomUrl();  // Navigate to a random URL
      VIEW.help();                 // Show the help text
    }
  };

  // Write the query back to the URL bar
  mod.browserWrite = function() {
    let tagsY = TAG_DOM.getChecked().join();
    let tagsN = TAG_DOM.getUnchecked().join();
    let xOrig = (FILTER.name() == "excluding_banned");

    let params = new URLSearchParams();
    if (tagsY) params.set(paramTagInclude, tagsY);
    if (tagsN) params.set(paramTagExclude, tagsN);
    if (xOrig) params.set(paramCrossOrigin, "true");
    let strParams = decodeURIComponent(params.toString());

    let url = new URL(window.location.href);
    url.search = "?" + strParams;
    window.history.replaceState({}, strParams, url);
  };

  return mod;
}(QUERY_STRING || {}));
