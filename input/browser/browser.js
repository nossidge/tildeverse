
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
var TAGS = ( function(mod) {

  mod.data = {
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

  return mod;
}(TAGS || {}));

//##############################################################################

// Module to read and set tag info.
var TAG_DOM = ( function(mod) {

  // Create and append the HTML elements for the tag buttons.
  mod.createTagElements = function() {
    let html = `
      <div class="btn-group btn-block" data-tag-name="@TAG@" title="@DESC@">
        <a tabindex="@INDEX@1" title="Exclude the '@TAG@' tag" id="tag_button_unchecked_@TAG@" data-filter-type="unchecked" class="btn btn-default btn-lg btn_glyph tag_button_unchecked" onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-remove"></div>
        </a>
        <a tabindex="@INDEX@2" title="Include the '@TAG@' tag" id="tag_button_checked_@TAG@" data-filter-type="checked" class="btn btn-default btn-lg btn_glyph tag_button_checked" onclick="TAG_DOM.toggleTagFilter(this);">
          <div class="glyphicon glyphicon-ok"></div>
        </a>
        <div title="(This is not actually a button)" id="tag_button_desc_@TAG@" data-tag-name="@TAG@" class="btn btn-default btn-lg tag_button_desc">@TAG@</div>
      </div>
    `;
    let elem = $("#tag_buttons");
    elem.empty();
    let index = 2;
    $.each(TAGS.data, function(tag, desc) {
      let tagHtml = html;
      tagHtml = tagHtml.replace(/@TAG@/g, tag);
      tagHtml = tagHtml.replace(/@DESC@/g, desc);
      tagHtml = tagHtml.replace(/@INDEX@/g, index + 2);
      elem.append(tagHtml);
      index++;
    });
  }

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
    return (mod.getChecked().length == Object.keys(TAGS.data).length);
  };
  mod.allUnchecked = function() {
    return (mod.getUnchecked().length == Object.keys(TAGS.data).length);
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
    USERS.filterByTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  };

  return mod;
}(TAG_DOM || {}));

//##############################################################################

// Module to store and filter users.
var USERS = ( function(mod) {
  let all = null;
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
        let obj = {
          site: site,
          user: user,
          url: url.replace("USER", user),
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
    }
    return filtered;
  };

  // Filter the homepage list by specific tags.
  // Also updates the page elements.
  // @param tagsInclude [Array<String>]
  // @param tagsExclude [Array<String>]
  mod.filterByTag = function(tagsInclude = [], tagsExclude = []) {
    let originalUser = mod.currentUser();

    TAG_DOM.handleSelectAllButtons();
    let newList = toIterator(all);
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
    mod.filtered(newList);
    populateDropdownURLs();

    // If the original user still exists in the filtered dataset,
    // then keep them selected.
    // Else, go to the first URL.
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
  }
  mod.previousUrl = function() {
    let user = data.previous().value;
    if (!user) data.next().value;
    USERS.displayCurrentUser();
  }
  mod.randomUrl = function() {
    data.random();
    USERS.displayCurrentUser();
  }
  mod.gotoUrlIndex = function(index) {
    data.gotoIndex(index);
    USERS.displayCurrentUser();
  }
  mod.gotoUrlOfUser = function(user) {
    data.gotoValue(user);
    USERS.displayCurrentUser();
  }

  return mod;
}(URL_NAVIGATION || {}));

//##############################################################################

// Module to control the tag select/deselect all buttons.
var TAG_MASS_SELECT = ( function(mod) {

  mod.toggleAllUnchecked = function(self) {
    if ($(self).hasClass("active")) {
      removeActive(".tag_button_unchecked");
    } else {
      addActive(".tag_button_unchecked");
      removeActive(".tag_button_checked");
    }
    USERS.filterByTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  }
  mod.toggleAllChecked = function(self) {
    if ($(self).hasClass("active")) {
      removeActive(".tag_button_checked");
    } else {
      addActive(".tag_button_checked");
      removeActive(".tag_button_unchecked");
    }
    USERS.filterByTag(TAG_DOM.getChecked(), TAG_DOM.getUnchecked());
  }

  function addActive(className) {
    $(className).each( function() { $(this).addClass("active"); })
  }
  function removeActive(className) {
    $(className).each( function() { $(this).removeClass("active"); })
  }

  return mod;
}(TAG_MASS_SELECT || {}));
