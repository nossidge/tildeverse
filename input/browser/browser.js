
// Find the difference of two arrays.
// https://stackoverflow.com/a/4026828/139299
Array.prototype.diff = function(a) {
  return this.filter( function(i) {
    return a.indexOf(i) < 0;
  });
};

//##############################################################################

// Turn an array into an iterator.
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

// UI improvements for accessibility.
var ACCESSIBILITY = ( function(mod) {

  // For anchors with a 'tabindex', call 'onclick' when space/enter is pressed.
  // Only run this when all DOM elements are loaded.
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

  return mod;
}(ACCESSIBILITY || {}));

//##############################################################################

// Module to store the info on each tag.
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

  // These sites have 'X-Frame-Options' set to 'sameorigin'
  mod.banned = ["tilde.team"];

  return mod;
}(INFO || {}));

//##############################################################################

// Module to read and set tag info.
var TAG_DOM = ( function(mod) {

  // For the 'browser' webapp:
  // Create and append the HTML elements for the tag buttons.
  mod.createTagElementsBrowser = function() {
    let html = `
      <div class="btn-group btn-block" data-tag-name="@TAG@" title="@DESC@">
        <a tabindex="@INDEX@1" title="Exclude the '@TAG@' tag" id="tag_button_unchecked_@TAG@" data-filter-type="unchecked" class="btn btn-default btn-lg btn_glyph tag_button_unchecked" onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-remove"></div>
        </a>
        <a tabindex="@INDEX@2" title="Include the '@TAG@' tag" id="tag_button_checked_@TAG@" data-filter-type="checked" class="btn btn-default btn-lg btn_glyph tag_button_checked" onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-ok"></div>
        </a>
        <div title="(This is not actually a button)" id="tag_button_desc_@TAG@" data-tag-name="@TAG@" class="btn btn-default btn-lg tag_button_desc no_pointer_events">@TAG@</div>
      </div>
    `;
    let elem = $("#tag_buttons");
    elem.empty();
    let index = 2;
    $.each(INFO.tags, function(tag, desc) {
      let tagHtml = html;
      tagHtml = tagHtml.replace(/@TAG@/g, tag);
      tagHtml = tagHtml.replace(/@DESC@/g, desc);
      tagHtml = tagHtml.replace(/@INDEX@/g, index + 2);
      elem.append(tagHtml);
      index++;
    });
  };

  // For the 'tagging' webapp:
  // Create and append the HTML elements for the tag buttons.
  mod.createTagElementsTagging = function() {
    let html = `
      <a id="tag_button_@TAG@" title="Add/remove the '@TAG@' tag"
          class="btn btn-default btn-lg btn_tags tag_button_desc tag_button"
          data-tag-name="@TAG@"
          onclick="TAG_STATE.toggleTag(this);">
        @TAG@
      </a>
    `;
    let elem = $("#tag_buttons");
    elem.empty();
    let index = 2;
    $.each(INFO.tags, function(tag, desc) {
      let tagHtml = html;
      tagHtml = tagHtml.replace(/@TAG@/g, tag);
      tagHtml = tagHtml.replace(/@DESC@/g, desc);
      tagHtml = tagHtml.replace(/@INDEX@/g, index + 2);
      elem.append(tagHtml);
      index++;
    });
  };

  // Return the status of the tags selected on the UI.
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

  // Handle the header 'select all' buttons.
  mod.allChecked = function() {
    return (mod.getChecked().length == Object.keys(INFO.tags).length);
  };
  mod.allUnchecked = function() {
    return (mod.getUnchecked().length == Object.keys(INFO.tags).length);
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

  // Display the users tags as active/inactive description buttons.
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

  // Toggle an button active state.
  // Also unchecks the opposite button.
  // Afterwards, filter by selected tags.
  mod.toggleTagFilter = function(element) {
    let thisFilter = $(element).attr("data-filter-type");
    let thatFilter = (thisFilter == "checked" ? "unchecked" : "checked");
    let opposite = $(element).parent().find(".tag_button_" + thatFilter);
    $(opposite).removeClass("active");
    $(element).toggleClass("active");
    FILTER_USERS.byTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };

  return mod;
}(TAG_DOM || {}));

//##############################################################################

// Module to store user arrays.
var USERS = ( function(mod) {
  let all = [];
  let filtered = null;

  // Set the underlying user array from the JSON object.
  // Convert JSON into an array of hashes.
  // Save to 'all' instance variable.
  mod.initialize = function(value) {
    all = [];
    let allSites = value["sites"];
    for (let site in allSites) {
      let url       = allSites[site]["url_format_user"];
      let siteUsers = allSites[site]["users"];
      for (let user in siteUsers) {
        let tags = siteUsers[user]["tags"];
        let date_tagged   = new Date(siteUsers[user]["tagged"]);
        let date_modified = new Date(siteUsers[user]["time"]);
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

  // Getter only.
  mod.all = function() {
    return all;
  };

  // Reference to the current user.
  mod.currentUser = function() {
    if (!filtered) return false;
    return filtered.current().value;
  };

  // Basic getter/setter.
  mod.filtered = function(value) {
    if (typeof value !== 'undefined') {
      filtered = value;
      URL_NAVIGATION.data(value);
      populateDropdownURLs();
    }
    return filtered;
  };

  // Display all the user's info on screen.
  mod.displayCurrentUser = function() {
    let user = mod.currentUser();

    if (typeof user !== "undefined") {
      mod.openCurrentInFrame();
      TAG_DOM.displayTags(user.tags);
      $("#text_user").attr("value", user.url);
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

  // Open the current Tilde user site in the iframe.
  mod.openCurrentInFrame = function() {
    if (typeof mod.currentUser() !== "undefined") {
      let elem = document.getElementById("url_iframe_link");
      elem.href = mod.currentUser().url;
      elem.click();
    }
  };

  // Open the current Tilde user site in a new tab.
  mod.openCurrentInNewTab = function() {
    if (typeof mod.currentUser() !== "undefined") {
      let elem = document.getElementById("url_blank_link");
      elem.href = mod.currentUser().url;
      elem.click();
    }
  };

  // Populate the input selection with the URLs.
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

// Module to filter USER arrays by various means.
var FILTER_USERS = ( function(mod) {

  // Filter the homepage list by specific tags.
  // Also updates the page elements.
  // @param tagsInclude [Array<String>]
  // @param tagsExclude [Array<String>]
  mod.byTag = function(tagsInclude = [], tagsExclude = []) {
    let originalUser = USERS.currentUser();

    TAG_DOM.handleSelectAllButtons();
    let newList = toIterator(USERS.all());
    if (tagsInclude != [] || tagsExclude != []) {
      newList = toIterator(
        newList.all().filter( function(user) {
          return tagsInclude.diff(user.tags).length === 0;
        })
      );
      newList = toIterator(
        newList.all().filter( function(user) {
          let diff = user.tags.diff(tagsExclude);
          return JSON.stringify(diff) == JSON.stringify(user.tags)
        })
      );
    }
    USERS.filtered(newList);
    gotoOriginal(newList, originalUser);
  };

  // Return users whose modified date is greater than their tagged date.
  mod.byNewlyUpdated = function() {
    let originalUser = USERS.currentUser();
    let newList = toIterator(
      USERS.all().filter( function(user) {
        return (user.date_modified > user.date_tagged);
      })
    );
    USERS.filtered(newList);
    gotoOriginal(newList, originalUser);
  };

  // Return users who have never been tagged.
  mod.byNeverTagged = function() {
    let originalUser = USERS.currentUser();
    let newList = toIterator(
      USERS.all().filter( function(user) {
        return (JSON.stringify(user.tags) == JSON.stringify(["-"]));
      })
    );
    USERS.filtered(newList);
    gotoOriginal(newList, originalUser);
  };

  // poo
  // Return users who are not banned from cross-origin iframe.
  // Also, tilde.town is over HTTPS, so exclude all sites that are HTTP.
  mod.byExcludingBanned = function() {
    let originalUser = USERS.currentUser();
    let newList = toIterator(
      USERS.all().filter( function(user) {
        let isBannedSite = INFO.banned.includes(user.site);
        let isHTTP = user.url.startsWith("http://");
        return (!isBannedSite && !isHTTP);
      })
    );
    USERS.filtered(newList);
    gotoOriginal(newList, originalUser);
  };

  // If the original user still exists in the filtered dataset,
  // then keep them selected.
  // Else, go to the first URL.
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

  return mod;
}(FILTER_USERS || {}));

//##############################################################################

// Module to control the top-left URL navigation buttons.
var URL_NAVIGATION = ( function(mod) {

  // The iterator object that contains the underlying data.
  let data = null;
  mod.data = function(value) {
    if (typeof value !== 'undefined') data = value;
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

// Module to handle buttons that act like option groups.
var TOGGLE_GROUPS = ( function(mod) {

  // Handle the tag select/deselect all buttons.
  mod.toggleAllUnchecked = function(self) {
    toggleEither(self, ".tag_button_unchecked", ".tag_button_checked");
    FILTER_USERS.byTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };
  mod.toggleAllChecked = function(self) {
    toggleEither(self, ".tag_button_checked", ".tag_button_unchecked");
    FILTER_USERS.byTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };
  function toggleEither(self, activeElements, linkedElements) {
    if ($(self).hasClass("active")) {
      MASS_CLASS.remove(activeElements, "active");
    } else {
      MASS_CLASS.add(activeElements, "active");
      MASS_CLASS.remove(linkedElements, "active");
    }
  }

  // Handle the filter by tag/moddate buttons.
  mod.toggleNeverTagged = function() {
    MASS_CLASS.add("#filter_by_never_tagged", "active");
    MASS_CLASS.remove("#filter_by_newly_updated", "active");
    FILTER_USERS.byNeverTagged();
  };
  mod.toggleNewlyUpdated = function() {
    MASS_CLASS.add("#filter_by_newly_updated", "active");
    MASS_CLASS.remove("#filter_by_never_tagged", "active");
    FILTER_USERS.byNewlyUpdated();
  };

  return mod;
}(TOGGLE_GROUPS || {}));

//##############################################################################

// Module to add/remove class for many elements at once.
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
