//package com.brewingmachine.config;
//
//import com.brewingmachine.dto.Result;
//import com.brewingmachine.service.AuthService;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Component;
//import org.springframework.web.filter.OncePerRequestFilter;
//
//import javax.servlet.FilterChain;
//import javax.servlet.ServletException;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.io.PrintWriter;
//
//@Component
//@RequiredArgsConstructor
//public class JwtAuthenticationFilter extends OncePerRequestFilter {
//
//    private final AuthService authService;
//    private final ObjectMapper objectMapper = new ObjectMapper();
//
//    @Override
//    protected void doFilterInternal(HttpServletRequest request,
//                                  HttpServletResponse response,
//                                  FilterChain filterChain) throws ServletException, IOException {
//
//        String requestURI = request.getRequestURI();
//
//        // 跳过不需要认证的路径
//        if (requestURI.startsWith("/login/") || requestURI.startsWith("/test/")) {
//            filterChain.doFilter(request, response);
//            return;
//        }
//
//        // 获取Authorization头
//        String authHeader = request.getHeader("Authorization");
//
//        // 检查是否以Bearer开头
//        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
//            sendUnauthorizedResponse(response, "缺少Authorization头或格式错误");
//            return;
//        }
//
//        String token = authHeader.substring(7); // 移除 "Bearer " 前缀
//
//        try {
//            // 验证token并获取用户ID
//            Long userId = authService.getUserIdByToken(token);
//
//            // 将用户ID放入请求属性中，供Controller使用
//            request.setAttribute("userId", userId);
//
//            filterChain.doFilter(request, response);
//
//        } catch (Exception e) {
//            sendUnauthorizedResponse(response, "Token验证失败: " + e.getMessage());
//        }
//    }
//
//    private void sendUnauthorizedResponse(HttpServletResponse response, String message) throws IOException {
//        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
//        response.setContentType("application/json;charset=UTF-8");
//
//        Result<Void> errorResult = Result.error(message);
//        String jsonResult = objectMapper.writeValueAsString(errorResult);
//
//        try (PrintWriter writer = response.getWriter()) {
//            writer.write(jsonResult);
//            writer.flush();
//        }
//    }
//}