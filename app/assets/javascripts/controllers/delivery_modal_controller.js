var DeliveryModalController = {
    initialize: function (params) {
        this.path = params.path;
        this.ajax_type = params.ajax_type;
        this.subscriptor = params.subscriptor;
        this.orderModifier = params.orderModifier;
        this.current_path = params.current_path;

        if (isPresent(window.user)) {
            this.addressService = new AddressService();

            var content_source = HandlebarsTemplates['delivery_selection']({
                path: this.path,
                addresses: window.addresses,
                preferredAddressId: this.addressService.getPreferredAddress()
            });

            var content = Handlebars.compile(content_source);

            var dialog = new Dialog({
                title: "Choose a delivery address",
                content: content,
                id: 'select-address',
                "class": 'select-address'
            });

            dialog.open();

            this.bindDeleteEvents();
            this.bindNewAddressEvents();
            this.bindSetAddressEvents(dialog);
        } else {
            this.redirect(DeliveryModalController.get_sign_in_redirect_path(this.path));
        }
    },

    bindDeleteEvents: function () {
        $("div.delete button").on("click", function (event) {
            var user_addr_id = $(this).data("user-addr-id");
            DeliveryModalController.handleDeleteClick(event, user_addr_id);
        });
    },

    bindNewAddressEvents: function () {
        $('.new-address-btn').on('click', function (event) {
            var path = $(event.currentTarget).data('merchant-path');
            if (path.indexOf('caterings') > 0) {
                path = path.replace('update_delivery_address', 'new');
            }
            DeliveryModalController.redirect('/user/address/new?path=' + encodeURIComponent(path));
        });
    },

    bindSetAddressEvents: function (dialog) {
        $('.set-btn').on('click', function (event) {
            DeliveryModalController.handleSetClick(event, dialog);
        });
    },

    get_sign_in_redirect_path: function (path) {
        var sign_in_path = "/sign_in/?";
        var location = $("input#past_location").val() || "";

        if (this.current_path) {
            sign_in_path += "continue_path=" + encodeURIComponent(this.current_path);
        }
        else {
            sign_in_path += "continue_path=" + encodeURIComponent(window.location.pathname);
        }

        if (this.orderModifier === "grouporder") {
            sign_in_path += "&admin_login=1";
        }
        if (location.length > 0) {
            sign_in_path += "&query_location=" + encodeURIComponent(location);
        }
        sign_in_path += "&query_delivery_path=" + encodeURIComponent(path);
        return sign_in_path;
    },

    handleSetClick: function (event, dialog) {
        var path = $(event.currentTarget).data('merchant-path');
        var addressID = $('.addresses :checked').val();

        this.addressService.storePreferredAddress(addressID);

        $('.set-btn').off('click', function (event) {
            DeliveryModalController.handleSetClick(event, dialog, this.addressService);
        });

        if (!!this.ajax_type) {
            if (this.ajax_type === 'GET') {
                var url = this.path + ("&user_addr_id=" + addressID);
                DeliveryModalController.setGetAjaxEvent(event, dialog, url);
            }
        } else {
            return this.redirect(path + ("&user_addr_id=" + addressID));
        }
    },

    handleDeleteClick: function (event, user_addr_id) {
        var dialog = UsersAddressController.prototype.showDeleteAddress(user_addr_id);
        $("div#delivery-address button[data-delete='yes']").click(function () {
            loadingPage.show();
        });
        DeliveryModalController.setAjaxEvent(event, dialog, user_addr_id);
    },

    setGetAjaxEvent: function (click_event, dialog, url) {
        $.ajax({
            url: url,
            method: "GET",
            success: function (data, textStatus, jqXHR) {
                DeliveryModalController.subscribeManagerGetAjaxResponse(data);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                var data = JSON.parse(jqXHR.responseText);
                if (isPresent(data.error)) {
                    var html_error = "<p id='error' class='message'><span class='message-body'>" + data.error + "</span><span class='close'>x</span></p>";
                    $('#flash_notifications').html(html_error);
                }
            },
            complete: function (jqXHR, textStatus) {
                dialog.close();
                loadingPage.hide();
            }
        });
        event.preventDefault();
    },

    subscribeManagerGetAjaxResponse: function (data) {
        if (this.subscriptor === 'update_address') {
            CateringNewController.prototype.updateDeliveryAddress(data);
        }
    },

    setAjaxEvent: function (click_event, dialog, user_addr_id) {
        $("div#delivery-address form").submit(function (event) {
            event.preventDefault();

            $.ajax({
                url: "/user/address/" + user_addr_id,
                method: "DELETE",
                data: $(this).serializeArray(),
                success: function (data, textStatus, jqXHR) {
                    DeliveryModalController.deleteAddress(click_event, data.user_addr_id);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                },
                complete: function (jqXHR, textStatus) {
                    dialog.close();
                    loadingPage.hide();
                }
            });
        });
    },

    deleteAddress: function (event, id) {
        var address = _.find(window.addresses, function (address) {
            return address.user_addr_id == id
        });
        window.addresses = _.without(window.addresses, address);
        $(event.target).parents("div#select-address div.addresses div.bordered").remove();

        if ($("div#select-address input:checked").length == 0) {
            var address_service = new AddressService();
            var addr_id = address_service.getPreferredAddress();
            $("div#select-address input:radio[value='" + addr_id + "']").prop("checked", true);
        }

        if ($("div#select-address input:checked").length == 0) {
            $("div#select-address input:radio").first().prop("checked", true);
        }
    },

    redirect: function (path) {
        return window.location.href = path;
    }
};

function get_param(url, field) {
    var href = url ? url : window.location.href;
    var reg = new RegExp("[?&]" + field + "=([^&#]*)", "i");
    var string = reg.exec(href);
    return string ? string[1] : null;
};
