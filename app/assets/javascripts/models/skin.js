var MOES = "moes";
var GOODCENTS = "goodcentssubs";
var OSF = "osf";

var Skin = (function () {
  function Skin(params) {
    if (params !== undefined) {
      this.skinName = params.skinName.toLowerCase().replace(" ", "");
      this.brandCustomFields = params.brandCustomFields || [];
      this.emailMarketingField = params.emailMarketingField;
      this.isPunchh = params.isPunchh || false;
      this.host = params.host
    }
  }

  Skin.prototype.isMoes = function() {
    return this.skinName == MOES;
  };

  Skin.prototype.isGoodCents = function() {
    return this.skinName == GOODCENTS || this.host == GOODCENTS;
  };

  Skin.prototype.isOsf = function() {
    return (this.skinName == OSF || this.host == OSF);
  };

  return Skin;
})();