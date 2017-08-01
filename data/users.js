
// Create the users table in the users tab.
function users(tildeverseJSON) {

  let tbody = document.createElement("tbody");
  $("#table_users").append(tbody);

  let row = '<tr><td><a href="SITE_URL">SITE_NAME</a></td><td>USER_NAME</td><td><a href="USER_URL">USER_URL_TIDY</a></td></tr>'

  for (let tildeSite in tildeverseJSON["sites"]) {
    let site = tildeverseJSON["sites"][tildeSite];
    $.each(site["users"], function(index, user) {
      let url = site["url_format_user"].replace("USER", user);
      let tidy = url.substring(url.indexOf("//") + 2);
      let out = row;
      out = out.replace("SITE_URL",      site["url_root"]);
      out = out.replace("SITE_NAME",     tildeSite);
      out = out.replace("USER_NAME",     user);
      out = out.replace("USER_URL",      url);
      out = out.replace("USER_URL_TIDY", tidy.replace(/\/$/, ""));
      $(tbody).append(out);
    });
  }

}
