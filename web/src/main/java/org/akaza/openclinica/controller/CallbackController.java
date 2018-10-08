package org.akaza.openclinica.controller;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import net.sf.json.util.JSONUtils;
import org.akaza.openclinica.bean.login.StudyUserRoleBean;
import org.akaza.openclinica.bean.login.UserAccountBean;
import org.akaza.openclinica.controller.helper.UserAccountHelper;
import org.akaza.openclinica.dao.login.UserAccountDAO;
import org.akaza.openclinica.service.CallbackService;
import org.akaza.openclinica.service.KeycloakUser;
import org.akaza.openclinica.service.StudyBuildService;
import org.apache.commons.lang.StringUtils;
import org.json.JSONObject;
import org.keycloak.KeycloakPrincipal;
import org.keycloak.KeycloakSecurityContext;
import org.keycloak.adapters.RefreshableKeycloakSecurityContext;
import org.keycloak.adapters.springsecurity.token.KeycloakAuthenticationToken;
import org.keycloak.representations.AccessToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;
import java.io.IOException;
import java.security.Principal;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import static org.akaza.openclinica.control.core.SecureController.USER_BEAN_NAME;

@SuppressWarnings("unused")
@Controller
public class CallbackController {


    @Autowired
    CallbackService callbackService;
    @Autowired
    KeycloakController keycloakController;

    protected final Logger logger = LoggerFactory.getLogger(getClass().getName());

    private final String redirectOnFail;
    private final String redirectOnSuccess;
    private String realm = "Protected";
    @Autowired private DataSource dataSource;
    @Autowired private UserAccountController userAccountController;
    @Autowired private StudyBuildService studyBuildService;
    @Autowired private UserAccountDAO userAccountDAO;

    public CallbackController() {
        this.redirectOnFail = "/error";
        this.redirectOnSuccess = "/MainMenu";
    }

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    protected void getCallback(final HttpServletRequest req, final HttpServletResponse res) throws Exception {
        handle(req, res);
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST, consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    protected void postCallback(final HttpServletRequest req, final HttpServletResponse res) throws Exception {
        handle(req, res);
    }

    private void handle(HttpServletRequest req, HttpServletResponse res) throws Exception {
        final Principal userPrincipal = req.getUserPrincipal();

        if (userPrincipal == null) {
            String authorizeUrl = keycloakController.buildAuthorizeUrl(req);
            logger.info("CallbackController In login_required:%%%%%%%%" + authorizeUrl);
            res.sendRedirect(authorizeUrl);
        } else if (userPrincipal instanceof KeycloakAuthenticationToken) {

            KeycloakPrincipal<KeycloakSecurityContext> kp = (KeycloakPrincipal<KeycloakSecurityContext>) ((KeycloakAuthenticationToken) userPrincipal).getPrincipal();
            AccessToken token = kp.getKeycloakSecurityContext().getToken();
            req.getSession().setAttribute("accessToken", kp.getKeycloakSecurityContext().getTokenString());
            KeycloakUser user = new KeycloakUser(token);

            String ocUserUuid = (String) user.getUserContext().get("userUuid");

            UserAccountHelper userAccountHelper = null;
            try {
                userAccountHelper = callbackService.isCallbackSuccessful(req, user);
            } catch (Exception e) {
                logger.error("UserAccountHelper:", e);
                throw e;
            }
            UserAccountBean ub = userAccountHelper.getUb();
            if (ub != null) {
                if (userAccountHelper.isUpdated()) {
                    ub = callbackService.getUpdatedUser(ub);
                }
                req.getSession().setAttribute(USER_BEAN_NAME, ub);
                refreshUserRole(req, ub);
                logger.info("Setting firstLoginCheck to true");
                req.getSession().setAttribute("firstLoginCheck", "true");
                logger.info("CallbackController set firstLoginCheck to true:%%%%%%%%");
            } else {
                logger.error("UserAccountBean ub ");
                unauthorized(res, "Bad credentials");
                return;
            }
            String returnTo = keycloakController.getReturnTo(req);
            String state = req.getParameter("state");
            String param = "";
            JSONObject jsonObject;
            if (JSONUtils.mayBeJSON(state)) {
                jsonObject = new JSONObject(state);

                Set<String> keySet = jsonObject.keySet();
                Object newJSON;
                for (String key : keySet) {
                    logger.debug(key);
                    newJSON = jsonObject.get(key);

                    if (StringUtils.isEmpty(param))
                        param += "?";
                    else
                        param += "&";
                    param += key + "=" + newJSON.toString();

                }
            }
            if (StringUtils.isEmpty(returnTo) || StringUtils.equals(returnTo, "/OpenClinica"))
                returnTo = this.redirectOnSuccess;
            logger.info("CallbackController returnTo URL:%%%%%%%%" + returnTo);
            logger.info("param:" + param);

            res.sendRedirect(returnTo + param);
        }

    }

    public RefreshableKeycloakSecurityContext getKeycloakSecurityContext() {
        HttpServletRequest request =
                ((ServletRequestAttributes) RequestContextHolder
                        .currentRequestAttributes()).getRequest();
        if (request.getAttribute(KeycloakSecurityContext.class.getName()) != null) {
            RefreshableKeycloakSecurityContext context = (RefreshableKeycloakSecurityContext) request.getAttribute(KeycloakSecurityContext.class.getName());
            return context;
        }
        return null;
    }
    private void refreshUserRole(HttpServletRequest req, UserAccountBean ub) {
        StudyUserRoleBean roleByStudy = ub.getRoleByStudy(ub.getActiveStudyId());
        req.getSession().setAttribute("userRole", roleByStudy);

    }
    private void unauthorized(HttpServletResponse response, String message) throws IOException {
        response.setHeader("WWW-Authenticate", "Basic realm=\"" + realm + "\"");
        response.sendError(401, message);
    }

    private void unauthorized(HttpServletResponse response) throws IOException {
        unauthorized(response, "Unauthorized");
    }

}
